'use strict'

const AWS = require('aws-sdk')
const s3 = AWS.S3()

exports.handler = async ({ Records }) => {
    return {
        statusCode:200,
        header: {
            'Content-type' : 'application/json'
        },
        body: 'Working'
    }
}
