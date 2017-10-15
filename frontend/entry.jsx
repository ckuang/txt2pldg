var React = require('react')
var ReactDOM = require('react-dom')
import {Router, Route, browserHistory} from 'react-router'

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
    let total = (parseInt(this.state.total) / 50000) * 1000

    return (
      <div>
        <div className="bar">
          <div className="outer-bar">
            <div className="inner-bar green" style={{width: total + "px"}}></div>
          </div>
        </div>

        <div className="labels">
          <div className="label">$10k</div>
          <div className="label">$20k</div>
          <div className="label">$30k</div>
          <div className="label">$40k</div>
          <div className="label">$50k</div>
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
