const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const sequelize = require('./models/index');
const Post = require('./models/Post');

const app = express();
#코드중에 port의 할당을 처음과 끝에서 두번 진행했는데 이유가 뭔지(혹시몰라서 GPT물어봤는데 오류 발생한다 답변)##
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

// DB connection
sequelize.authenticate()
    .then(() => console.log('DB 연결 성공'))
    .catch(err => console.error('DB 연결 실패:', err));

sequelize.sync();

// Read
app.get('/posts', async (req, res) => {
    const posts = await Post.findAll({ order: [['id', 'DESC']] });
    res.json(posts);
});

app.get('/posts/:id', async (req, res) => {
    const post = await Post.findByPk(req.params.id);
    if (!post) {
        return res.status(404).json({ message: '게시글을 찾을 수 없습니다.' });
    }
    res.json(post);
});

// create
app.post('/posts', async (req, res) => {
    const { title, content } = req.body;
    if (!title || !content) {
        return res.status(400).json({ message: '제목과 내용을 입력하세요.' });
    }
    const newPost = await Post.create({ title, content });
    res.json({ message: '게시글 작성 완료', post: newPost });
});

// update
app.put('/posts/:id', async (req, res) => {
    const { title, content } = req.body;
    const post = await Post.findByPk(req.params.id);
    if (!post) {
        return res.status(404).json({ message: '게시글을 찾을 수 없습니다.' });
    }
    await post.update({ title, content });
    res.json({ message: '게시글 수정 완료', post });
});

// delete
app.delete('/posts/:id', async (req, res) => {
    const post = await Post.findByPk(req.params.id);
    if (!post) {
        return res.status(404).json({ message: '게시글을 찾을 수 없습니다.' });
    }
    await post.destroy();
    res.json({ message: '게시글 삭제 완료' });
});

const port = 3000;
app.listen(port, () => {
    console.log(`서버 실행 중: http://localhost:${port}`);
});
