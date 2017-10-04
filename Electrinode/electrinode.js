
const listeners = []
function on(cb) {
    //listeners.shift();
    listeners.push(cb);
}
__electrinode.listen(message => {
    for (var i=0; i<listeners.length; i++) {
        listeners[i](message)
    }
})

const send = __electrinode.send

const api = {on, send}

api.httpStarted = url => send({_type: 'httpStarted', url})
api.ping = data => send({_type: 'ping', data})
api.fastPing = data => send({_type: 'fastPing', data})

module.exports = api

