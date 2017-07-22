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

## Testing deployment to production with minikube

### Requirements:

[Minikube and Kubectl][minikube] >= v.1.6.0

### Procedure

* Start minikube

```bash
minikube start
# to get inside
minikube ssh
# to see IP
minikube ip
# for this example lets assume the output to be 192.168.42.201
```

* Create namespace

```bash
kubectl create ns gn
```

* Create the project (from the project root)

```bash
kubectl create -f k8s/dev/
kubectl create -f k8s/pv-claims/
kubectl create -f k8s/
```

* Monitor the progress with

```bash
kubectl get -n gn pod
```

the output should look like

```bash
NAME                        READY     STATUS    RESTARTS   AGE
gnlist-2922274414-95zwd     0/1       Running   0          19s
gnlist-2922274414-npf2t     0/1       Running   0          19s
gnlist-2922274414-qpwsv     0/1       Running   0          19s
gnlist-db-503522788-113lt   1/1       Running   0          19s
```

to monitor the progress on a pod

```bash
kubectl logs -f -n gn gnlist-2922274414-95zwd
```

to get inside of a pod

```bash
kubectl exec -it -n gn gnlist-2922274414-95zwd bash
```

* To access the project via browser

When all pods are ready

```bash
NAME                        READY     STATUS    RESTARTS   AGE
gnlist-2922274414-95zwd     1/1       Running   0          3m
gnlist-2922274414-npf2t     1/1       Running   0          3m
gnlist-2922274414-qpwsv     1/1       Running   0          3m
gnlist-db-503522788-113lt   1/1       Running   0          3m
```

```bash
kubectl get -n gn services
# or
kubectl gen -n gn svc
```

```bash
NAME        CLUSTER-IP   EXTERNAL-IP   PORT(S)          AGE
gnlist      10.0.0.19    <nodes>       80:32741/TCP     5m
gnlist-db   10.0.0.109   <nodes>       5432:30586/TCP   5m
```

In this example the outside port that can be reached is `32741`.
If `minikube ip` returned `192.168.42.201` point your browser to
`http://192.168.42.201:32741`

* To clean everything up

```bash
kubectl delete ns gn
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
[minikube]: https://kubernetes.io/docs/tasks/tools/install-minikube/
