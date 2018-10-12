# docker-opengrok
Docker image for [OpenGrok](http://oracle.github.io/opengrok/) with Universal Ctags.

>OpenGrok is a fast and usable source code search and cross reference engine. 

# Usage
```sh
docker run -d -v <directory with files to be indexed>:/src -p <PORT>:8080 thombashi/opengrok
```

OpenGrok Web user interface can be accessed at `http://<HOST>:<PORT>/source/`
after the first source code indexing completed.


# Docker Image Includes
- `OpenGrok 1.0`
- [Universal Ctags]( https://github.com/universal-ctags/ctags )
- Auto reindexing triggered by changes of the directory with files to be indexed
    - [inotify-tools]( https://github.com/rvoicilas/inotify-tools )
- [Git]( https://git-scm.com/ )
- [tomcat 8.5]( http://tomcat.apache.org/ )
