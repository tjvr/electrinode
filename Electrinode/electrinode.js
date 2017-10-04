
const listeners = []
function on(cb) {
    listeners.push(cb);
}
__electrinode.listen(message => {
    for (var i=0; i<listeners.length; i++) {
        listeners[i](message)
    }
})

function send(_type, ..._arguments) {
  __electrinode.send({_type, _arguments})
}

const api = {on, send}

api.httpStarted = url => __electrinode.send({_type: 'httpStarted', url})
api.ping = data => __electrinode.send({_type: 'ping', data})

module.exports = api

