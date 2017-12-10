# Mongo ORM
This shard provides a basic ORM for using MongoDB wth the Crystal programming language.
Mongo ORM is based on [Granite ORM](https://github.com/amberframework/granite-orm),
and provides basic querying, associations, and model lifecycle capabilities. Mongo ORM
is intended to be used with the [Amber Framework](https://github.com/amberframework/amber),
but can be used with vanilla crystal or any web framework.

Suggestions, feature requests, bug fixes, and pull requests are always welcome.

## Installation
First you will need to install MongoDB, as well as the dependencies for [Mongo.cr](https://github.com/datanoise/mongo.cr).
On Linux, this can be done by running the following bash script from the root of your
crystal project directory or from `/tmp` (untested).

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

Next, add the following to the `shards.yml` file in your project and run `shards install`:
```yml
# shards.yml
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
WIP
