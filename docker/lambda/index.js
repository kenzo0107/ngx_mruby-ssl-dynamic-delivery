'use strict';

const DynamoDB = require('aws-sdk/clients/dynamodb');
const tableName = process.env.TABLE_NAME;
const docClient = new DynamoDB.DocumentClient({
  apiVersion: '2012-08-10',
  endpoint: 'http://dynamodb-local:8000',
});

// 有効なドメインを指定し証明書情報等のデータ取得
const getDataForEnalbedDomain = async (domainName) => {
  return await docClient
    .get(
      {
        TableName: tableName,
        Key: {
          domain: domainName,
        },
      },
      (err, data) => {}
    )
    .promise();
};

exports.handler = async (event, context, callback) => {
  console.log(event);
  const domain = event['domain'];
  const r = await getDataForEnalbedDomain(domain);
  return callback(null, r);
};
