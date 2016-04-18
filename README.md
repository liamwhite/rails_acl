# Rails_ACL
(Yet another) dead-simple, fast, pure Ruby ACL module for Rails applications.

This project is mostly a rewrite of [CanCanCan](https://github.com/CanCanCommunity/cancancan), please check that out first! You probably don't want this gem.

## Why?
The two most popular Rails authorization frameworks are CanCanCan and Pundit.

I was not happy with the performance of CanCanCan; in a similarl vein, its overly complex codebase makes it difficult to even understand what's going on in there, let alone audit it.
Pundit is extremely simple and beautiful. However, _it is not an ACL-based framework._ I was not exactly fond of the idea of writing a ton of policy classes for use in Pundit.

## Usage
See CanCanCan documentation; authorization is mostly unchanged. You may find it wise to read over the Ability module to understand how it works.
