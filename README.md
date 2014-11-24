# fluent-plugin-lambda

Output plugin for [AWS Lambda](http://aws.amazon.com/lambda/).

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-lambda.svg)](http://badge.fury.io/rb/fluent-plugin-lambda)
[![Build Status](https://travis-ci.org/winebarrel/fluent-plugin-lambda.svg?branch=master)](https://travis-ci.org/winebarrel/fluent-plugin-lambda)

## Installation

    $ gem install fluent-plugin-lambda

## Configuration

```
<match lambda.**>
  type lambda
  #profile ...
  #credentials_path ...
  #aws_key_id ...
  #aws_sec_key ...
  region us-east-1
  #endpoint ...

  function_name my_func
  # Pass the function name in the key of record if the function name is not set

  # include_time_key false
  # include_tag_key false
</match>
```

## Usage

When the function name is set:

```sh
echo '{"key":"value"}' | fluent-cat lambda.foo
```

When the function name is not set:

```sh
echo '{"function_name":"my_func", "key":"value"}' | fluent-cat lambda.bar
```
