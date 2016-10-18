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
    let total = parseInt(this.state.total)
    let widthA = 0, widthB = 0, widthC = 0
    if (total > 0 && total <= 10000) {
      widthA = (total / 10000) * 250
    } else if (total > 10000 && total <= 20000) {
      widthA = 250
      widthB = ((total - 10000) / 10000) * 250
    } else if (total > 20000 && total < 30000) {
      widthA = 250
      widthB = 250
      widthC = ((total - 20000) / 10000) * 250
    } else if (total > 30000) {
      widthA = 250
      widthB = 250
      widthC = 250
    }
    return (
      <div>
        <div className="bar">
          <div className="outer-bar-1">
            <div className="inner-bar light-green" style={{width: widthA + "px"}}></div>
          </div>
          <div className="outer-bar-2">
            <div className="inner-bar green" style={{width: widthB + "px"}}></div>
          </div>
          <div className="outer-bar-3">
            <div className="inner-bar dark-green" style={{width: widthC + "px"}}></div>
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
  fetchMessages: function() {
    var that = this
    $.ajax({
      url: '/message',
      type: 'get',
      success: function(response) {
        that.setState({pledges: response.pledges})
        if (that.state.idx + 1 < response.pledges.length) {
          that.setState({idx: that.state.idx + 1})
        } else {
          that.setState({idx: 0})
        }
      }
    })
  },
  componentDidMount: function() {
    var that = this
    setInterval(
      function(){
        that.fetchMessages()
      }, 1500)
  },
  render: function() {
    if (!this.state.pledges) {
      return(<div/>)
    } else {
      var person = this.state.pledges[this.state.idx]
      var message = this.state.pledges[this.state.idx].message
      if (message) {
        var output = <div className="donor-message">"{message}"</div>
      } else {
        var output = <div/>
      }
    return (
          <div className="message">
            <div className="donor-amount">{person.donor.name} pledged ${numberWithCommas(person.amount)}</div>
            {output}
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
