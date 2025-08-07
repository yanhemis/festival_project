// server.js (Node.js + Express + MySQL)

require('dotenv').config(); // .env 파일 로드
const express = require('express');
const mysql = require('mysql2/promise'); // promise 기반 MySQL 드라이버 사용
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');
const cors = require('cors');
const AWS = require('aws-sdk'); // AWS SDK 임포트

const app = express();
const port = process.env.PORT || 3001;

// CORS 설정: Flutter 앱 (localhost:XXXXX)에서 접근 허용
app.use(cors({
    origin: ['http://localhost:54308', 'http://10.0.2.2:3001'], // 개발 단계에서는 모든 출처 허용. 프로덕션에서는 Flutter 앱의 정확한 출처로 변경해야 함.
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

// JSON 요청 본문 파싱 미들웨어
app.use(express.json());

// MySQL 연결 풀 생성
const pool = mysql.createPool({
    host: process.env.DB_HOST, // Docker Compose에서 MySQL 서비스 이름 (예: mysql-db)
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// AWS SDK 설정 (백엔드에서 Cognito API 호출용)
AWS.config.update({
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    region: process.env.AWS_REGION
});
const cognitoidentityserviceprovider = new AWS.CognitoIdentityServiceProvider();

// Cognito ID Token 검증을 위한 JWKS 클라이언트 설정
const client = jwksClient({
    jwksUri: `https://cognito-idp.${process.env.COGNITO_REGION}.amazonaws.com/${process.env.COGNITO_USER_POOL_ID}/.well-known/jwks.json`
});

function getKey(header, callback) {
    client.getSigningKey(header.kid, function(err, key) {
        const signingKey = key.publicKey || key.rsaPublicKey;
        callback(null, signingKey);
    });
}

// JWT 검증 미들웨어
const verifyToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    if (!authHeader) {
        return res.status(401).json({ message: 'Authorization header is missing' });
    }

    const token = authHeader.split(' ')[1]; // "Bearer TOKEN" 에서 TOKEN 부분 추출
    if (!token) {
        return res.status(401).json({ message: 'Token is missing' });
    }

    jwt.verify(token, getKey, { algorithms: ['RS256'] }, (err, decoded) => {
        if (err) {
            console.error('JWT verification failed:', err);
            return res.status(403).json({ message: 'Invalid token' });
        }
        req.user = decoded; // 디코딩된 JWT 페이로드를 req.user에 저장
        next();
    });
};

// --- API 라우트 정의 ---

// 헬스 체크
app.get('/', (req, res) => {
    res.status(200).send('Local Backend API is running!');
});

// 사용자 정보 저장 또는 업데이트 (인증 필요)
// 클라이언트는 cognitoId만 보내고, 나머지 정보는 백엔드가 Cognito에서 가져옵니다.
app.post('/users', verifyToken, async (req, res) => {
    const { cognitoId } = req.body; // 클라이언트에서 Cognito sub ID만 받음
    const { sub } = req.user; // JWT에서 추출된 Cognito sub ID (토큰의 유효성 검증 후)

    // 보안 강화: JWT의 sub와 요청 본문의 cognitoId가 일치하는지 확인
    if (sub !== cognitoId) {
        return res.status(403).json({ message: 'Cognito ID mismatch. The authenticated user does not match the requested user.' });
    }

    let connection;
    try {
        connection = await pool.getConnection();

        // 1. Cognito에서 사용자 상세 정보 조회
        const getUserParams = {
            UserPoolId: process.env.COGNITO_USER_POOL_ID,
            Username: cognitoId // Cognito의 username은 보통 sub 또는 이메일
        };
        const cognitoUser = await cognitoidentityserviceprovider.adminGetUser(getUserParams).promise();
        console.log('Cognito User Details fetched from AWS:', JSON.stringify(cognitoUser, null, 2));

        // Cognito 사용자 속성 파싱
        let email = '';
        let name = null;
        let profilePictureUrl = null;

        cognitoUser.UserAttributes.forEach(attr => {
            switch (attr.Name) {
                case 'email':
                    email = attr.Value;
                    break;
                case 'name':
                    name = attr.Value;
                    break;
                case 'picture': // 소셜 로그인 시 프로필 사진 URL
                    profilePictureUrl = attr.Value;
                    break;
                // 필요한 다른 Cognito 속성도 여기에 추가하여 파싱할 수 있습니다.
                // 예: case 'custom:my_custom_attribute': myCustomAttribute = attr.Value; break;
            }
        });

        // 2. MySQL에 저장할 사용자 데이터 준비
        const userToSave = {
            id: sub, // id는 Cognito sub와 동일하게 (PRIMARY KEY)
            cognito_id: sub, // Cognito ID 필드
            email: email,
            name: name,
            profile_picture_url: profilePictureUrl,
        };

        // 3. MySQL에 사용자 정보 저장 또는 업데이트
        // 사용자가 이미 존재하는지 확인 (cognito_id 기준)
        const [rows] = await connection.execute('SELECT id FROM users WHERE cognito_id = ?', [cognitoId]);

        if (rows.length > 0) {
            // 사용자 업데이트
            await connection.execute(
                'UPDATE users SET email = ?, name = ?, profile_picture_url = ?, updated_at = CURRENT_TIMESTAMP WHERE cognito_id = ?',
                [userToSave.email, userToSave.name, userToSave.profile_picture_url, userToSave.cognito_id]
            );
            console.log(`User ${cognitoId} updated in MySQL DB.`);
            res.status(200).json({ message: 'User updated successfully', user: userToSave });
        } else {
            // 새 사용자 생성
            await connection.execute(
                'INSERT INTO users (id, cognito_id, email, name, profile_picture_url) VALUES (?, ?, ?, ?, ?)',
                [userToSave.id, userToSave.cognito_id, userToSave.email, userToSave.name, userToSave.profile_picture_url]
            );
            console.log(`New user ${cognitoId} inserted into MySQL DB.`);
            res.status(201).json({ message: 'User created successfully', user: userToSave });
        }
    } catch (error) {
        console.error('Database or Cognito API operation failed:', error);
        // Cognito AdminGetUser 오류일 수 있음 (예: 권한 부족)
        if (error.code === 'AccessDeniedException' || error.statusCode === 403) {
            res.status(403).json({ message: 'Backend server has insufficient permissions to access Cognito user data.', error: error.message });
        } else if (error.code === 'UserNotFoundException') {
            res.status(404).json({ message: 'Cognito user not found.', error: error.message });
        } else {
            res.status(500).json({ message: 'Internal server error during user sync.', error: error.message });
        }
    } finally {
        if (connection) connection.release(); // 연결 해제
    }
});

// 특정 사용자 정보 조회 (인증 필요)
app.get('/users/:cognitoId', verifyToken, async (req, res) => {
    const { cognitoId } = req.params;
    const { sub } = req.user;

    // 보안 강화: JWT의 sub와 요청된 cognitoId가 일치하는지 확인 (다른 사용자 정보 조회 방지)
    if (sub !== cognitoId) {
        return res.status(403).json({ message: 'Access denied: You can only view your own user data.' });
    }

    let connection;
    try {
        connection = await pool.getConnection();
        const [rows] = await connection.execute('SELECT * FROM users WHERE cognito_id = ?', [cognitoId]);

        if (rows.length > 0) {
            res.status(200).json(rows[0]);
        } else {
            res.status(404).json({ message: 'User not found in local DB.' });
        }
    } catch (error) {
        console.error('Database query failed:', error);
        res.status(500).json({ message: 'Internal server error during user fetch.', error: error.message });
    } finally {
        if (connection) connection.release();
    }
});

// 서버 시작
app.listen(port, () => {
    console.log(`Local Backend API running at http://localhost:${port}`);
    console.log(`Connected to MySQL database: ${process.env.DB_NAME} on ${process.env.DB_HOST}:${process.env.DB_PORT}`);
});

// 오류 핸들링
process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err);
    process.exit(1);
});
