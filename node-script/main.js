const axios = require("axios");
const fs = require('fs');

const datas = JSON.parse(fs.readFileSync('./request.json'))
const url = 'YOUR API URL'

console.log('Data Length:' + datas.length)

const sendRequest = async (data) => {
        try {
            await axios({
                method: 'post',
                url,
                data
            });
        } catch(error) {
            console.error(error.message + JSON.stringify(data, 2, null))
        }
}

console.time('100-elements');
let promises = []
for(const data of datas) {
    promises.push(sendRequest(data))
}
Promise.all(promises)
.then(res => console.log(res.length))

console.timeEnd('100-elements');

