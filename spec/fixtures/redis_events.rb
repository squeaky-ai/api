# frozen_string_litral: true

module Fixtures
  class RedisEvents
    def initialize(event, timestamp = Time.now.to_i * 1000)
      @site_id = event['site_id']
      @session_id = event['session_id']
      @timestamp = timestamp
    end

    def create_recording(args = {})
      key = redis_key('recording')

      item = {
        locale: 'en-GB',
        width: '1920',
        height: '1080',
        useragent: 'Firefox',
        **args
      }

      Redis.current.hset(key, item)
    end

    def create_page_view(args = {})
      key = redis_key('pageviews')

      item = {
        path: '/',
        timestamp: @timestamp,
        **args
      }

      Redis.current.lpush(key, item.to_json)
    end

    def create_event(args = {})
      key = redis_key('events')

      item = {
        type: '0',
        data: {},
        timestamp: @timestamp,
        **args
      }

      Redis.current.lpush(key, item.to_json)
    end

    def create_base_events
      key = redis_key('events')

      events = [
        {type: '4', timestamp: @timestamp,        data: {href:'http://localhost:8080/examples/static/',width:1915,height:1387,locale:'en-GB',useragent:'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:93.0) Gecko/20100101 Firefox/93.0'} },
        {type: '2', timestamp: @timestamp + 4,    data: {node:{id:1,type:0,childNodes:[{id:2,name:'html',type:1,publicId:'',systemId:''},{id:3,type:2,tagName:'html',attributes:{},childNodes:[{id:4,type:2,tagName:'head',attributes:{},childNodes:[{id:5,type:3,textContent:'\n    '},{id:6,type:2,tagName:'title',attributes:{},childNodes:[{id:7,type:3,textContent:'Test'}]},{id:8,type:3,textContent:'\n    '},{id:9,type:3,textContent:'\n    '},{id:10,type:3,textContent:'\n  '}]},{id:11,type:3,textContent:'\n  '},{id:12,type:2,tagName:'body',attributes:{},childNodes:[{id:13,type:3,textContent:'\n    '},{id:14,type:2,tagName:'form',attributes:{class:'form'},childNodes:[{id:15,type:3,textContent:'\n      '},{id:16,type:2,tagName:'div',attributes:{},childNodes:[{id:17,type:3,textContent:'\n        '},{id:18,type:2,tagName:'label',attributes:{'for':'email'},childNodes:[{id:19,type:3,textContent:'Email'}]},{id:20,type:3,textContent:'\n        '},{id:21,type:2,tagName:'input',attributes:{name:'email',type:'email'},childNodes:[]},{id:22,type:3,textContent:'\n      '}]},{id:23,type:3,textContent:'\n\n      '},{id:24,type:2,tagName:'div',attributes:{},childNodes:[{id:25,type:3,textContent:'\n        '},{id:26,type:2,tagName:'label',attributes:{'for':'password'},childNodes:[{id:27,type:3,textContent:'Password'}]},{id:28,type:3,textContent:'\n        '},{id:29,type:2,tagName:'input',attributes:{name:'password',type:'password'},childNodes:[]},{id:30,type:3,textContent:'\n      '}]},{id:31,type:3,textContent:'\n\n      '},{id:32,type:2,tagName:'div',attributes:{},childNodes:[{id:33,type:3,textContent:'\n        '},{id:34,type:2,tagName:'label',attributes:{'for':'age'},childNodes:[{id:35,type:3,textContent:'Age'}]},{id:36,type:3,textContent:'\n        '},{id:37,type:2,tagName:'select',attributes:{name:'age','value':'***'},childNodes:[{id:38,type:3,textContent:'\n          '},{id:39,type:2,tagName:'option',attributes:{'value':'old','selected':true},childNodes:[{id:40,type:3,textContent:'Old'}]},{id:41,type:3,textContent:'\n          '},{id:42,type:2,tagName:'option',attributes:{'value':'young'},childNodes:[{id:43,type:3,textContent:'Young'}]},{id:44,type:3,textContent:'\n        '}]},{id:45,type:3,textContent:'\n      '}]},{id:46,type:3,textContent:'\n\n      '},{id:47,type:2,tagName:'button',attributes:{type:'submit'},childNodes:[{id:48,type:3,textContent:'Submit'}]},{id:49,type:3,textContent:'\n    '}]},{id:50,type:3,textContent:'\n\n    '},{id:51,type:2,tagName:'a',attributes:{href:'http://localhost:8080/examples/static/page-1.html',class:'link'},childNodes:[{id:52,type:3,textContent:'Page 1'}]},{id:53,type:3,textContent:'\n    '},{id:54,type:3,textContent:'\n  \n\n'}]}]}]},'initialOffset':{'top':0,'left':0}} },
        {type: '3', timestamp: @timestamp + 1844, data: {source:1,positions:[{x:1228,y:1228,id:3,timeOffset:0}]} },
        {type: '3', timestamp: @timestamp + 2099, data: {adds:[],texts:[],source:0,removes:[],attributes:[{id:3,attributes:{class:' mavqwwlcwb'}}]} },
        {type: '3', timestamp: @timestamp + 2107, data: {adds:[],texts:[],source:0,removes:[],attributes:[{id:3,attributes:{class:' mavqwwlcwb idc0_332'}}]} },
        {type: '3', timestamp: @timestamp + 2547, data: {source:1,positions:[{x:1227,y:1227,id:3,timeOffset:-436},{x:1221,y:1215,id:3,timeOffset:-386},{x:1221,y:1215,id:3,timeOffset:-303},{x:1198,y:1145,id:3,timeOffset:-253},{x:1184,y:1101,id:3,timeOffset:-203},{x:1144,y:944,id:3,timeOffset:-153},{x:1124,y:896,id:3,timeOffset:-103},{x:1117,y:890,id:3,timeOffset:-53}]} },
        {type: '3', timestamp: @timestamp + 3047, data: {source:1,positions:[{x:1116,y:890,id:3,timeOffset:-486},{x:1079,y:883,id:3,timeOffset:-419},{x:1073,y:883,id:3,timeOffset:-353},{x:1078,y:885,id:3,timeOffset:-93},{x:1076,y:869,id:3,timeOffset:-36}]} },
        {type: '3', timestamp: @timestamp + 3552, data: {source:1,positions:[{x:1066,y:861,id:3,timeOffset:-491},{x:1032,y:832,id:3,timeOffset:-424},{x:980,y:797,id:3,timeOffset:-374},{x:699,y:637,id:3,timeOffset:-308},{x:555,y:552,id:3,timeOffset:-258},{x:546,y:542,id:3,timeOffset:-208}]} },
        {type: '3', timestamp: @timestamp + 4043, data: {source:1,positions:[{x:546,y:542,id:3,timeOffset:-233},{x:544,y:534,id:3,timeOffset:-176},{x:543,y:531,id:3,timeOffset:-125},{x:539,y:521,id:3,timeOffset:-59},{x:536,y:501,id:3,timeOffset:-9}]} },
        {type: '3', timestamp: @timestamp + 4544, data: {source:1,positions:[{x:511,y:437,id:3,timeOffset:-459},{x:496,y:414,id:3,timeOffset:-393},{x:496,y:411,id:3,timeOffset:-343},{x:496,y:411,id:3,timeOffset:-205},{x:517,y:432,id:3,timeOffset:-143}]} },
        {type: '3', timestamp: @timestamp + 5045, data: {source:1,positions:[{x:525,y:439,id:3,timeOffset:-400},{x:510,y:417,id:3,timeOffset:-345},{x:474,y:377,id:3,timeOffset:-294},{x:359,y:279,id:3,timeOffset:-227},{x:309,y:239,id:3,timeOffset:-160},{x:214,y:147,id:3,timeOffset:-94},{x:184,y:113,id:12,timeOffset:-44}]} },
        {type: '3', timestamp: @timestamp + 5337, data: {id:21,type:5,source:2} },
        {type: '3', timestamp: @timestamp + 5444, data: {x:123,y:23,id:21,type:2,source:2} },
        {type: '3', timestamp: @timestamp + 5532, data: {source:1,positions:[{x:164,y:83,id:14,timeOffset:-495},{x:150,y:61,id:32,timeOffset:-445},{x:137,y:45,id:29,timeOffset:-395},{x:130,y:35,id:29,timeOffset:-345},{x:126,y:28,id:21,timeOffset:-295},{x:123,y:24,id:21,timeOffset:-245}]} },
        {type: '3', timestamp: @timestamp + 5663, data: {id:21,text:'*',source:5,isChecked:false} },
        {type: '3', timestamp: @timestamp + 5681, data: {id:21,text:'**',source:5,isChecked:false} },
        {type: '3', timestamp: @timestamp + 5792, data: {id:21,text:'***',source:5,isChecked:false} },
        {type: '3', timestamp: @timestamp + 5792, data: {id:21,text:'****',source:5,isChecked:false} },
        {type: '3', timestamp: @timestamp + 5945, data: {id:21,text:'*****',source:5,isChecked:false} },
        {type: '3', timestamp: @timestamp + 6010, data: {id:21,text:'******',source:5,isChecked:false} },
        {type: '3', timestamp: @timestamp + 6243, data: {source:1,positions:[{x:123,y:23,id:21,timeOffset:0}]} },
        {type: '3', timestamp: @timestamp + 6315, data: {id:29,type:5,source:2} },
        {type: '3', timestamp: @timestamp + 6387, data: {id:21,type:6,source:2} },
        {type: '3', timestamp: @timestamp + 6503, data: {x:133,y:45,id:29,type:2,source:2} },
        {type: '3', timestamp: @timestamp + 5620, data: {source:1,positions:[{x:128,y:34,id:29,timeOffset:-444},{x:132,y:41,id:29,timeOffset:-394},{x:133,y:45,id:29,timeOffset:-343}]} },
        {type: '3', timestamp: @timestamp + 5724, data: {id:29,text:'*',source:5,isChecked:false} },
        {type: '3', timestamp: @timestamp + 5764, data: {id:29,text:'**',source:5,isChecked:false} },
        {type: '3', timestamp: @timestamp + 5930, data: {id:29,text:'***',source:5,isChecked:false} },
        {type: '3', timestamp: @timestamp + 6174, data: {id:29,text:'****',source:5,isChecked:false} },
        {type: '3', timestamp: @timestamp + 6175, data: {id:29,text:'*****',source:5,isChecked:false} },
        {type: '3', timestamp: @timestamp + 6236, data: {id:29,text:'******',source:5,isChecked:false} },
        {type: '3', timestamp: @timestamp + 6392, data: {source:1,positions:[{x:133,y:45,id:29,timeOffset:0}]} },
        {type: '3', timestamp: @timestamp + 6723, data: {id:29,type:6,source:2} },
        {type: '3', timestamp: @timestamp + 6834, data: {x:816,y:165,id:3,type:2,source:2} }
      ]

      events.each { |e| Redis.current.lpush(key, e.to_json) }
    end

    private

    def redis_key(prefix)
      "#{prefix}::#{@site_id}::#{@session_id}"
    end
  end
end

