'use strict'

const AWS = require('aws-sdk')
const SNS = new AWS.SNS()
const Joi = require('joi')

const tipicArn = process.env.TOPIC_ARN

const schema = Joi.object().keys({
    user_name: Joi.string().required(),
    product_value: Joi.number().required(),
    creditCard_number: Joi.string().required(),
    product_name: Joi.string().required()
})

const isValidData = (data) => {
    return schema.validate(data)
}

const publishMessage = async (data) => {
    const params = {
        Message: JSON.stringify(data),
        Subject: 'New Payment',
        TopicArn: tipicArn
    }
    await SNS.publish(params).promise()
}

exports.handler = async ( { body } ) => {
    if(!body) {
        const response = {
            statusCode: 400,
            headers: {
            'Content-Type': 'application/json',
            },
            body: 'Body não enviado'
        }
        return response
    }
    const data = isValidData(JSON.parse(body))
    if(data.error) { 
        return {
            statusCode: 400,
            headers: {
            'Content-Type': 'application/json',
            },
            body: JSON.stringify(data.error.details, null, 2)
        }
    }
    try {
        await publishMessage(data)
        return {
            statusCode: !data.error ? 200 : 400,
            headers: {
            'Content-Type': 'application/json',
            },
            body:  !data.error ? 'Payment Criado' : JSON.stringify(data.error.details, null, 2)
        }

    } catch (error) {
        return {
            statusCode: 500,
            headers: {
            'Content-Type': 'application/json',
            },
            body:  'Error' + error.message
        }
    }
}
