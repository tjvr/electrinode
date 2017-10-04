

const electrinode = require('./electrinode')


electrinode.on(e => console.log('JS got:', e))

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

class Fred {
  constructor(name) { this.name = name }

  toJSON() {
    return 4;
  }
}

const PORT = 32912
server.listen(PORT, '127.0.0.1', () => {
  const {address, port} = server.address()
  const url = 'http://' + address + ':' + port
  console.log('running at ', url)
  
  electrinode.httpStarted(url)

  function rtt() {
    const [s, ns] = process.hrtime()
    //console.log(s, ns)
    electrinode.ping('pong')
    electrinode.on(d => {
      if (d == 'pong') {
        const [e, ne] = process.hrtime()
        //console.log(e, ne)
        console.log((ne - ns) + 'ns elapsed')

        rtt()
      }
    })
  }
  rtt()

  // {
  //   test: new String("moo"),
  //   number: Number(3.14442221), 
  //   array: [4, 5, 6],
  //   fred: new Fred('Freddie'),
  //   nan: NaN,
  //   null: null,
  //   undef: undefined,
  // });
})

