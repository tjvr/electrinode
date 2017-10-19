

console.log('hello')

setInterval(() => {
    console.log('yo')
}, 100)

/*
const electrinode = require('./electrinode')

const http = require('http')
const fs = require('fs')

const app = (req, res) => {
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

// TODO check port isn't in use
server.listen(0, '127.0.0.1', () => {
  const {address, port} = server.address()
  const url = 'http://' + address + ':' + port
  console.log('running at ', url)
  
  electrinode.httpStarted(url + '/index.html')

  var ponger = 0
  function rtt() {
    const id = ponger++
    const [s, ns] = process.hrtime()
    //console.log(s, ns)
    electrinode.on(d => {
      if (d == id || (d._type == 'moo' && d.data == id)) {
        const [e, ne] = process.hrtime()
        //console.log(e, ne)
        console.log(''+id, (e - s)+'s', (ne - ns)/1000 + 'us elapsed')

        setTimeout(rtt)
      }
    })

    // about 0.9ms
    //electrinode.fastPing(id)
    
    // about 2+ms including DispatchQueue round-trip
    //electrinode.ping(id)
    
    //electrinode.send(id)
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

// TODO figure out how to kick UV when we send() from Swift
//setInterval(() => {}, 0)

*/
