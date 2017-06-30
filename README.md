# Global Names List Resolver User Interface

A web-based GUI for [gn_list_resolver]. The [gn_list_resolver] Ruby gem allows
comparison of one scientfic names checklist to another.

[![Continuous Integration Status][ci-svg]][ci]
[![Code Climate][code-svg]][code]
[![Test Coverage][test-svg]][test]
[![Dependency Status][deps-svg]][deps]
[![Join the chat at https://gitter.im/GlobalNamesArchitecture/gnlist-resolver-gui][gitter-svg]][gitter]

## Testing

* install docker
* install docker-compose
* run

```bash
docker-compose up
docker-compose run app rake
```

## Development

We recommend to use docker-compose for development

To prepare the system (if you run it first time or
there was an update in the code) go to the project's
root and then

```bash
docker-compose down # if it is running

sudo chown -R `whoami` # for Linux only (Windows, Mac do it for you)

docker-compose build
```

Start it all:

```bash
docker-compose up
```

Point your browser to `http://0.0.0.0:9292`

For testing purposes you can use [this csv file][csv-file]

To stop it run

```bash
docker-compose down
```

[ci-svg]: https://circleci.com/gh/GlobalNamesArchitecture/gnlist-resolver-gui.svg?style=shield
[ci]: https://circleci.com/gh/GlobalNamesArchitecture/gnlist-resolver-gui
[code-svg]: https://codeclimate.com/github/GlobalNamesArchitecture/gnlist-resolver-gui/badges/gpa.svg
[code]: https://codeclimate.com/github/GlobalNamesArchitecture/gnlist-resolver-gui
[test-svg]: https://codeclimate.com/github/GlobalNamesArchitecture/gnlist-resolver-gui/badges/coverage.svg
[test]: https://codeclimate.com/github/GlobalNamesArchitecture/gnlist-resolver-gui
[deps-svg]: https://gemnasium.com/GlobalNamesArchitecture/gnlist-resolver-gui.svg
[deps]: https://gemnasium.com/GlobalNamesArchitecture/gnlist-resolver-gui
[Guard]: https://github.com/guard/guard
[gn_list_resolver]: https://github.com/GlobalNamesArchitecture/gn_list_resolver
[csv-file]: https://raw.githubusercontent.com/GlobalNamesArchitecture/gn_list_resolver/master/spec/files/all-fields-semicolon.csv
[gitter-svg]: https://badges.gitter.im/GlobalNamesArchitecture/gnlist-resolver-gui.svg
[gitter]: https://gitter.im/GlobalNamesArchitecture/gnlist-resolver-gui?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge

