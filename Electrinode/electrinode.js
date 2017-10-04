
const listeners = []
function on(cb) {
    listeners.push(cb);
}
__electrinode.listen(message => {
    for (var i=0; i<listeners.length; i++) {
        listeners[i](message)
    }
})

function send(kind, payload) {
  __electrinode.send(Object.assign({_type: kind}, payload))
}

module.exports = {on, send}

