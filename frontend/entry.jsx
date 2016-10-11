var React = require('react')
var ReactDOM = require('react-dom')

var Hello = React.createClass({
  render: function() {
    console.log('hello')
    return (
      <div>Hello World</div>
    )
  }
})

document.addEventListener("DOMContentLoaded", function() {
  ReactDOM.render(
    <Hello />,
    document.getElementById('content')
  )
})
