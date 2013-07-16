root = exports ? this

TIME_RANGE = 10*60*1000
TICKS = 10
REFRESH_INTERVAL = 1000
CHECK_INTERVAL = 5000
TIME_FORMAT = "%H:%M"

class LiveChart
  constructor: (options) ->
    @ele = options.ele
    @dataUrl = options.dataUrl
    
    @checkInterval = options.checkInterval || CHECK_INTERVAL
    @timeRange = options.timeRange || TIME_RANGE
    @ticks = options.ticks || TICKS
    @timeFormat = options.timeFormat || TIME_FORMAT
    @refreshInterval = options.refreshInterval || REFRESH_INTERVAL
    @percentage = options.percentage

    @data = []
    @_data = {}
    @plot = null
    @fetching = false
    @showing = false

    @fetchData() if @dataUrl
    @showData()


  getOptions: (time) ->
    options = {
      series:
        shadowSize: 0
        lines:
          show: true
      legend:
        position: 'nw'
      xaxis:
        mode: "time"
        tickSize: [parseInt(@timeRange/1000/@ticks), "second"]
        timeformat: @timeFormat
        timezone: "browser"
        min: time - @timeRange
        max: time
    }

    if @percentage
      options.yaxis =
        min: 0
        max: 100
        tickFormatter: (v) =>
          return v + "%"

    return options


  showData: ->
    return if @showing
    @showing = true
    @_showData()
  _showData: ->
    now = Date.now()
    @plot = @ele.plot(@data, @getOptions(now)).data("plot")
    @plot.setData(@data)
    @plot.setupGrid()
    @plot.draw()

    setTimeout =>
      @_showData()
    , @refreshInterval


  fetchData: ->
    return if @fetching
    @fetching = true
    @_fetchData()
  _fetchData: ->
    $.getJSON @dataUrl, (data) =>
      @setData(data)
    setTimeout =>
      @_fetchData()
    , @checkInterval


  setData: (data) ->
    min = Date.now() - @timeRange
    for key, val of data
      @_data[key] ?= []
      @_data[key].push val
    for label, vals in @_data
      vals.shift() while (vals[0] and vals[0][0] < min)
      delete @_data[label] if vals.length == 0

    @data = []
    for k,v of @_data
      @data.push
        data: v
        label: k


root.LiveChart = LiveChart
