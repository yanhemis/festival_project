const AWS = require("aws-sdk");
const dynamo = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const now = new Date().toISOString();

  const claims = event.requestContext.authorizer.claims;

  const userId = claims.sub;
  const email = claims.email;

  const body = JSON.parse(event.body);

  const item = {
    user_id: userId,
    created_at: now,
    email: email,
    nickname: body.nickname || "사용자",
    grade: "common",
    platform: body.platform || "app",
    point: 1500,
    profile_image: body.profile_image || "",
    push_consent: body.push_consent || "no"
  };

  const params = {
    TableName: "Users",
    Item: item
  };

  try {
    await dynamo.put(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify({ message: "User info saved successfully" })
    };
  } catch (err) {
    console.error("DB error:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Internal Server Error" })
    };
  }
};
