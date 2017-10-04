
const listeners = []
function on(cb) {
    listeners.push(cb);
}
__electrinode.listen(message => {
    for (var i=0; i<listeners.length; i++) {
        listeners[i](message)
    }
})

function send(message) {
  __electrinode.send(message)
}

module.exports = {on, send}

