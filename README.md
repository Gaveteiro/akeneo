[![CircleCI](https://circleci.com/gh/awniemeyer/akeneo.svg?style=svg&circle-token=1d727274a65e61f2bd5f2208f5c33bf532ebaac5)](https://circleci.com/gh/awniemeyer/akeneo)

# akeneo

API client for accessing Akeneo.

Usage:

```ruby
require 'akeneo'

client = Akeneo::API.new(
  url: 'https://my.akeneo.instance.com',
  client_id: '1337',
  password: 'tb9iiXWKskG2AFsKDaexyNf',
  secret: 'F3vpu3p0ezUmwW6nit5eVqt',
  username: 'API Username'
)

client.product(511707)
# => {"identifier"=>"511707", "family"=>"simple_product", "parent"=>nil, "groups"=>[]...

Some methods with parameters is inside services classes, and be called that way
client.family_service.all
# => Returns a Enumeration to list all families

client.product_service.create(object)
# => Returns a JSON with status code relative to what happened
201: CREATED
"{"line":1,"identifier":"bot","status_code":201}"

204: NO CONTENT/UPDATED
"{"line":1,"identifier":"top","status_code":204}"

422: UNPROCESSABLE ENTITY/ERROR
In this case, returns message too
"{"line":1,"identifier":"bot","status_code":422,"message":"Validation failed.","errors":[{"property":"values","message":"The value Top 2 vezes is already set on another product for the unique attribute nome_marketing","attribute":"nome_marketing","locale":null,"scope":null}]}"
```

Returns options from attribute
```
options = client.attribute_service.options(codigo_do_atributo)

options["_embedded"]["items"].map{|a| [a['code'], a['labels']]}
```

## Configuration

### Caching

If you want to use redis as a caching layer you have to set the `REDIS_URL` ENV variable.
By default the request will be cached for 5 Minutes.
You can alter the cache expiration via the `AKENEO_CACHE_EXPIRES_IN` ENV variable.

Caching is enabled by default whenever you have redis running.
You can disable caching completely by setting
`Akeneo::Cache.disabled = true` before you use the service.
