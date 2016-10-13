var React = require('react')
var ReactDOM = require('react-dom')


function numberWithCommas(x) {
  return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

var Total = React.createClass({
  getInitialState: function() {
    return({total: 0})
  },
  componentDidMount: function() {
    var that = this
    setInterval(
      function(){
          $.ajax({
          url: '/total',
          type: 'get',
          success: function(response) {
            that.setState({total: response.total})
          }
        })
      }, 2000)
  },
  render: function() {
    return (
      <div>
        <div className="bar">
          <div className="outer-bar-1">
            <div className="inner-bar" style={{width: (parseInt(this.state.total) / 30000 * 725 )+ "px"}}></div>
          </div>
          <div className="outer-bar-2">
            <div className="inner-bar" style={{width: (parseInt(this.state.total) / 30000 * 725 )+ "px"}}></div>
          </div>
          <div className="outer-bar-3">
            <div className="inner-bar" style={{width: (parseInt(this.state.total) / 30000 * 725 )+ "px"}}></div>
          </div>
        </div>

        <div className="labels">
          <div className="label">$10k</div>
          <div className="label">$20k</div>
          <div className="label">$30k</div>
        </div>

        <div className="total-pledged">
          Total Pledged: <span className="amount">${numberWithCommas(parseInt(this.state.total))}</span>
        </div>
      </div>
    )
  }
})

var Message = React.createClass({
  getInitialState: function() {
    return ({idx: 0, pledges: null})
  },
  componentDidMount: function() {
    var that = this
    setInterval(
      function(){
          $.ajax({
          url: '/message',
          type: 'get',
          success: function(response) {
            that.setState({pledges: response.pledges})
          }
        })
      }, 2000)
    setInterval(function() {
        if (that.state.idx + 1 < that.state.pledges.length) {
          that.setState({idx: that.state.idx + 1})
        }
      }, 3000)
  },
  render: function() {
    if (!this.state.pledges) {
      return(<div/>)
    } else {
      var person = this.state.pledges[this.state.idx]
      return (
        <div className="message">
          <div className="donor-amount">{person.donor.name} just pledged ${numberWithCommas(person.amount)}</div>
          <div className="donor-message">"{person.message}"</div>
        </div>
      )
    }
  }
})

var App = React.createClass({
  render: function() {
    return(
      <div>
        <Total />
        <Message />
      </div>
    )
  }
})

document.addEventListener("DOMContentLoaded", function() {
  ReactDOM.render(
    <App />,
    document.getElementById('total')
  )
})
