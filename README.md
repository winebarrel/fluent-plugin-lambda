# fluent-plugin-lambda

Output plugin for [AWS Lambda](http://aws.amazon.com/lambda/).

[![GitHub version](https://badge.fury.io/gh/VAveryanov8%2Ffluent-plugin-lambda-ext.svg)](https://badge.fury.io/gh/VAveryanov8%2Ffluent-plugin-lambda-ext)
[![Build Status](https://travis-ci.org/VAveryanov8/fluent-plugin-lambda-ext.svg?branch=master)](https://travis-ci.org/VAveryanov8/fluent-plugin-lambda-ext)

**This is a fork of [fluent-plugin-lambda](https://github.com/winebarrel/fluent-plugin-lambda)**

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

  #qualifier staging
  function_name my_func
  # Set 'group_events' true for making batch requests
  #group_events true
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
