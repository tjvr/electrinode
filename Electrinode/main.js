
console.log("Hello world!");

console.log(process.title);

//require('../MacOS/Electrinode')
hello()

const http = require('http')


const app = (req, res) => {
    // TODO randomize version param in index.html
    if (req.url === '/' || /^\/app\.js\?/.test(req.url)) {
        res.writeHead(200, {
                      'Content-Type': 'text/html',
                      'Cache-Control': 'max-age=0',
        })
        res.end("<style>body { font-family: -apple-system; }</style><h3>Hello world!")
    } else {
        res.end('not found: ' + req.url)
    }
}

const server = http.createServer(app)

// Your app needs the "Incoming Connections (Server)" entitlement

// TODO if Node takes >250ms to boot the web server,
// then the initial HTTP request will fail

const PORT = 32912
server.listen(PORT, '127.0.0.1', () => {
  const {address, port} = server.address()
  console.log('running at http://' + address + ':' + port)
})

