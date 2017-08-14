# Nginx / Consul-Template Demo

Purpose of this project is to provide a complete demo environment to show dynamic backend load-balancing using Nginx and Consul Template.

## Pre-Requisites

- `docker-machine` installed
- `virtualbox` installed
- `docker` installed (17.06 or greater)

## Instructions

### 1. Clone this repo and change into the directory.

```
$ git clone git@github.com:johnharris85/nginx-consul-template-demo.git
$ cd nginx-consul-template-demo
```

### 2. Create the nodes:

```
$ ./bootstrap-docker-machine.sh 3
$ docker-machine ls -q
node1
node2
node3
```

### 3. Bootstrap all the core components:

```
$ ./bootstrap-containers.sh
### Bootstrapping core components... ###
[...]
### Completed bootstrapping core components... ###
```

Two browser windows should appear:

- Consul UI
- Nginx App LB

### 4. (Optional) Add extra backend services to demonstrate dynamic balancing in Nginx:

```
$ ./add-app-backends.sh
[...]
```

Take a look at the Consul UI and you should see the number of `app` services has scaled up to 9. Hit refresh on the Nginx LB page and notice it balance between multiple backends.

You can remove them again by running:

```
$ ./remove-app-backends.sh
[...]
```

Check the number of `app` backends has scaled back down to 3 in the Consul UI.

### 5. Cleanup all core components:

```
$ ./cleanup-containers.sh
```

### 6. Cleanup `docker-machine` nodes:

```
$ docker-machine rm node{1..3}
```

## TODO

- Remove `--net=host` requirement from most containers
- Migrate most of the work to the `stack.yml` file
- Add kubernetes implementation

## Support

If you have questions or hit issues please let me know by filing an [issue](https://github.com/johnharris85/nginx-consul-template-demo/issues/new) against the project.