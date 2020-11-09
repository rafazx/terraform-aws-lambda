'use strict'

const AWS = require('aws-sdk')
const dynamo = new AWS.DynamoDB.DocumentClient()
const { v4: uuidv4 } = require('uuid')

const createDocument = async (data) => {
    data.paymentId = uuidv4();
    const params = {
        TableName: process.env.DYNAMODB_TABLE,
        Item: data
    }
    return await dynamo.put(params).promise()
}

const transformDatatoJson = (object) => {
    const body = JSON.parse(object.body)
    const message = JSON.parse(body.Message)
    const data = message.value
    return data
}

exports.handler = async ( { Records } ) => {
    if(Records) {
        try {
            let promises = []
            for(const record of Records) {
                const data = transformDatatoJson(record)
                promises.push(createDocument(data))
            }
            await Promise.all(promises)
            .then(res => console.log('******Finish'))
        } catch(error) {
            console.log('*********Error: ' + error.message)
        }
    }
}

