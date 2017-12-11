# Mongo ORM
This shard provides a basic ORM for using MongoDB wth the Crystal programming language.
Mongo ORM is based on [Granite ORM](https://github.com/amberframework/granite-orm),
and provides basic querying, associations, and model lifecycle capabilities. Mongo ORM
is intended to be used with the [Amber Framework](https://github.com/amberframework/amber),
but can be used with vanilla crystal or any web framework.

Suggestions, feature requests, bug fixes, and pull requests are always welcome.

## Installation
First you will need to [install MongoDB](https://docs.mongodb.com/v3.4/administration/install-community/)
(unless you are running a remote server), as well as the dependencies for
[Mongo.cr](https://github.com/datanoise/mongo.cr). On Linux, this can be done by running
the following bash script from the root of your crystal project directory or from
`/tmp` (untested).

```bash
# install_linux_deps.sh
#!/bin/bash
mkdir -p lib || exit 1
cd lib || exit 1
wget https://github.com/mongodb/mongo-c-driver/releases/download/1.1.0/mongo-c-driver-1.1.0.tar.gz || exit 1
tar -zxvf mongo-c-driver-1.1.0.tar.gz && cd mongo-c-driver-1.1.0/ || exit 1
./configure --prefix=/usr --libdir=/usr/lib || exit 1
make -j4 || exit 1
sudo make install -j4 || exit 1
```

Next, add the following to the `shard.yml` file in your project and run `shards install`:
```yml
# shard.yml
dependencies:
  mongo-orm:
    github: sam0x17/crystal-mongo-orm
```

## Establishing MongoDB Connection
By default (with zero configuration), Mongo ORM will attempt to connect to a database
running at `localhost:27017` which is the default MongoDB port, with the database
name `monogo_orm_db`.

### Using Environment Variables
If the environment variable `DATABASE_URL` is present, Mongo ORM will connect using
this variable instead. You can also specify the database name using the `DATABASE_NAME`
environment variable. For example:

```
$ DATABASE_URL=mongodb://localhost:11771;DATABASE_NAME=my_db crystal .
```

### Using a YAML Configuration File
If the `DATABASE_URL` environment variable is not present, Mongo ORM will look for the
file `config/database.yml` within your project directory. If the file exists, Mongo
ORM will expect the following format (specify the keys `database_url` and
`database_name`):

```yaml
# config/database.yml
database_url: mongodb://localhost:11771
database_name: my_db
```

## Mongo ORM Reference

### Defining Standard Models
MongoDB is different from conventional relational database systems mainly because there
is no set-in-stone schema, but instead a "wilderness" of BSON-based "documents" that
may or may not roughly follow the same schema. Declaring a model works much the same
as it does in Granite ORM:

```crystal
class User < Mongo::ORM::Document
  field name : String
  field age : Int32
  field deleted_at : Time
  field turned_on : Bool
  timestamps
end
```

This will declare a model called `User` with a string field called `name`, a 32-bit
integer field called `age`, a Time field called `deleted_at`, a boolean field called
`turned_on`, and the standard `created_at` and `updated_at` fields you will recognize
from Rails that are created because we specified `timestamps`.

Note: all Time fields are presently locked into UTC because of some conversion bugs
that arise when changing time zones and converting between BSON and crystal models.

To instantiate a `User` and save it to the database, you can do:

```crystal
user = User.new
user.name = "Sam"
user.age = 248
user.turned_on = true
user.save!
puts user.inspect # print the created user
puts "id: #{user._id}" # print the ID of the created user
```
Note that the `ID` field is named `_id`, as in standard MongoDB.

You can also use the more compact `create` notation:

```crystal
user = User.create name: "Sam", age: 248, turned_on: true
```

### Model Associations
Currently, you can define `has_many` associations directly on a model, and they will
behave roughly the same way they would in standard Rails. For example:

```crystal
class Group < Mongo::ORM::Document
  field name : String
  has_many :users
end
```
This defines another model called `Group`. A group has a String field `name`, and
has an ID-based collection of `User` documents called `users` which can be accessed
via `group.users` where `group` is an instance of `Group`. To make a `User` a member
of a `Group`, `user.group_id` can be set to the document ID of an already-created
`Group`. Note that when you specify that model A `has_many` model B, the `b.a_id` field
is also automatically created.

### Embedded Documents
In addition to conventional table-style models/documents, Mongo ORM supports the
ability to embed documents or collections of documents within documents, as per the
BSON standard. This is sometimes a more convenient or more efficient alternative
to spreading data out across multiple document collections and fully leverages
the document-based nature of MongoDB. See the example below:

```crystal
class Topic < Mongo::ORM::Document
  embeds top_comment : Comment # e.g. topic.top_comment.body
end

class Tag < Mongo::ORM::EmbeddedDocument
  field topic : String
end

class Comment < Mongo::ORM::EmbeddedDocument
  field body : String
  embeds_many :tags # e.g. comment.tags[0]
end
```
