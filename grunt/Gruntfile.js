'use strict';
module.exports = function(grunt) {

  /**
   * String.toCapitalize
   */
  if ( !String.prototype.toCapitalize ) {
    String.prototype.toCapitalize = function() {
      return this.charAt(0).toUpperCase() + this.slice(1);
    }
  }

  /**
   * String.replaceAll
   */
  if ( !String.prototype.replaceAll ) {
    String.prototype.replaceAll = function($search, $replacement) {
      var $target = this.toString();
      $target = $target.split($search);
      $target = $target.join($replacement);
      $target = $target.toString();
      return $target;
    };
  }

  /**
   * require dependencies
   */
  require('load-grunt-tasks')(grunt, {
    pattern: ['grunt-*', '@*/grunt-*'],
    scope: ['dependencies', 'devDependencies', 'peerDependencies', 'optionalDependencies'],
    requireResolution: false
  });

  var fs = fs || require('fs'),
    path = path || require('path');

  var $projectIgnores = [
    'node_modules',
    'www',
    'subl',
  ];

  var $frameworks = {
    magento: {
      less: {
        app:        'PROJECT/skin/frontend/PACKAGE/TEMPLATE/less/app.less',
        bootstrap:  'PROJECT/skin/frontend/PACKAGE/TEMPLATE/less/bootstrap.less',
      },
      autoprefixer: {
        app:        'PROJECT/skin/frontend/PACKAGE/TEMPLATE/css/app.css',
        bootstrap:  'PROJECT/skin/frontend/PACKAGE/TEMPLATE/css/bootstrap.css',
      },
      cssmin: {
        app:        'PROJECT/skin/frontend/PACKAGE/TEMPLATE/css/app.min.css',
        bootstrap:  'PROJECT/skin/frontend/PACKAGE/TEMPLATE/css/bootstrap.min.css',
      },
      concat: {
        dev: {
          src: [
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/dev/app.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/dev/configs.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/dev/modules.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/dev/controllers.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/dev/directives.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/dev/factorys.js"
          ],
          dest: 'PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/app.js'
        },
        angular: {
          src: [
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/angularjs/app.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/angularjs/configs.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/angularjs/modules.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/angularjs/controllers.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/angularjs/directives.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/angularjs/factorys.js"
          ],
          dest: 'PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/app.js',
        },
        angularjs: {
          src: [
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/angularjs/app.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/angularjs/configs.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/angularjs/modules.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/angularjs/controllers.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/angularjs/directives.js",
            "PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/angularjs/factorys.js"
          ],
          dest: 'PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/app.js',
        },
      },
      ngAnnotate: {
        app: 'PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/app.js',
      },
      uglify: {
        app: 'PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/app.min.js',
      },
      watch: {
        less: [
          'PROJECT/skin/frontend/PACKAGE/TEMPLATE/less/**/*.less',
        ],
        css: [
          'PROJECT/skin/frontend/PACKAGE/TEMPLATE/less/**/*.less',
        ],
        js: [
          'PROJECT/skin/frontend/PACKAGE/TEMPLATE/dev/**/*.js',
          'PROJECT/skin/frontend/PACKAGE/TEMPLATE/angularjs/**/*.js',
          'PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/dev/**/*.js',
          'PROJECT/skin/frontend/PACKAGE/TEMPLATE/js/angularjs/**/*.js',
        ]
      },
    },
    wordpress: {
      less: {
        app:        'PROJECT/wp-content/PACKAGE/TEMPLATE/less/app.less',
      },
      autoprefixer: {
        app:        'PROJECT/wp-content/PACKAGE/TEMPLATE/css/app.css',
      },
      cssmin: {
        app:        'PROJECT/wp-content/PACKAGE/TEMPLATE/css/app.min.css',
      },
      concat: {
        dev: {
          src: [
            "PROJECT/wp-content/PACKAGE/TEMPLATE/js/dev/app.js",
            "PROJECT/wp-content/PACKAGE/TEMPLATE/js/dev/modules.js",
            "PROJECT/wp-content/PACKAGE/TEMPLATE/js/dev/controllers.js",
            "PROJECT/wp-content/PACKAGE/TEMPLATE/js/dev/directives.js",
            "PROJECT/wp-content/PACKAGE/TEMPLATE/js/dev/factorys.js"
          ],
          dest: 'PROJECT/wp-content/PACKAGE/TEMPLATE/js/app.js'
        },
        angular: {
          src: [
            "PROJECT/wp-content/PACKAGE/TEMPLATE/angularjs/app.js",
            "PROJECT/wp-content/PACKAGE/TEMPLATE/angularjs/modules.js",
            "PROJECT/wp-content/PACKAGE/TEMPLATE/angularjs/controllers.js",
            "PROJECT/wp-content/PACKAGE/TEMPLATE/angularjs/directives.js",
            "PROJECT/wp-content/PACKAGE/TEMPLATE/angularjs/factorys.js"
          ],
          dest: 'PROJECT/wp-content/PACKAGE/TEMPLATE/js/app.js',
        },
        angularjs: {
          src: [
            "PROJECT/wp-content/PACKAGE/TEMPLATE/js/angularjs/app.js",
            "PROJECT/wp-content/PACKAGE/TEMPLATE/js/angularjs/modules.js",
            "PROJECT/wp-content/PACKAGE/TEMPLATE/js/angularjs/controllers.js",
            "PROJECT/wp-content/PACKAGE/TEMPLATE/js/angularjs/directives.js",
            "PROJECT/wp-content/PACKAGE/TEMPLATE/js/angularjs/factorys.js"
          ],
          dest: 'PROJECT/wp-content/PACKAGE/TEMPLATE/js/app.js',
        },
      },
      ngAnnotate: {
        app: 'PROJECT/wp-content/PACKAGE/TEMPLATE/js/app.js',
      },
      uglify: {
        app: 'PROJECT/wp-content/PACKAGE/TEMPLATE/js/app.min.js',
      },
      watch: {
        less: [
          'PROJECT/wp-content/PACKAGE/TEMPLATE/less/**/*.less',
        ],
        css: [
          'PROJECT/wp-content/PACKAGE/TEMPLATE/css/**/*.css',
          '!PROJECT/wp-content/PACKAGE/TEMPLATE/css/**/*.min.css',
        ],
        js: [
          'PROJECT/wp-content/PACKAGE/TEMPLATE/dev/**/*.js',
          'PROJECT/wp-content/PACKAGE/TEMPLATE/angularjs/**/*.js',
          'PROJECT/wp-content/PACKAGE/TEMPLATE/js/dev/**/*.js',
          'PROJECT/wp-content/PACKAGE/TEMPLATE/js/angularjs/**/*.js',
        ]
      },
    },
  };

  var $initConfig = {
    less: {
      options: {},
    },
    autoprefixer: {
      options: {
        browsers: ['> 1%', 'last 200 versions', 'ie 8', 'ie 7'],
        remove: true
      },
    },
    cssmin: {
      options: {
        shorthandCompacting: false,
        roundingPrecision: -1
      },
    },
    concat: {
      options: {
        separator: '\n',
        stripBanners: false
      },
    },
    ngAnnotate: {
      options: {
        singleQuotes: true
      },
    },
    uglify: {
      options: {
        compress: {
          drop_console: true
        },
        mangle: true,
        maxLineLen: 32000,
        preserveComments: false
      },
    },
    watch: {},
  };

  var D = {
    $sources: [
      'D:/server/www/dev/',
      'D:/server/www/live/',
    ],
    getDirectories: function ($srcpath) {
      try {
        return fs.readdirSync($srcpath).filter(function($file) {
          var $isIgnore = false;
          $projectIgnores.forEach(function($element, $index, $array) {
            if($file.indexOf($element) >= 0) {
              $isIgnore = true;
            }
          });
          if($isIgnore) {
            return false;
          }
          $file = path.join($srcpath, $file);
          return fs.statSync($file).isDirectory();
        });
      } catch (e) {
        // console.log(e);
      }
    },
    getFiles: function ($srcpath) {
      try {
        return fs.readdirSync($srcpath).filter(function($file) {
          var $isIgnore = false;
          $projectIgnores.forEach(function($element, $index, $array) {
            if($file.indexOf($element) >= 0) {
              $isIgnore = true;
            }
          });
          if($isIgnore) {
            return false;
          }
          $file = path.join($srcpath, $file);
          return fs.statSync($file).isFile();
        });
      } catch (e) {
        // console.log(e);
      }
    },
    is_array: function($array, $callback, $isFirstOnly) {
      if( typeof $isFirstOnly == 'undefined' ) {
        $isFirstOnly = true;
      }
      try {
        for (var $key in $array) {
          if (!$array.hasOwnProperty($key)) continue;
          try {
            $callback($key, $array[$key]);
          } catch (e) {
            console.log(e);
          }
          if($isFirstOnly) {
            break;
          }
        }
      } catch (e) {
        console.log(e);
      }
    },
    is_file: function($path, $callback) {
      try {
        fs.accessSync($path, fs.F_OK);
        $callback($path);
      } catch (e) {
        // console.log(e);
      }
    },
    is_dir: function($path, $callback) {
      try {
        fs.accessSync($path, fs.F_OK);
        $callback($path);
      } catch (e) {
        // console.log(e);
      }
    },
    has_file: function($src, $file) {
      var $lists = Object($src);
      for (var $key in $lists) {
        if (!$lists.hasOwnProperty($key)) continue;
        if ($lists[$key].indexOf($file) >= 0) {
          return $key;
        }
      }
      return -1;
    },
    has_length: function($obj) {
      var $size = 0, $_key;
      for ($_key in $obj) {
        if ($obj.hasOwnProperty($_key)) {
          $size++;
        }
      }
      return $size;
    },
    projects: function() {
      var $_roots = new Array();
      D.is_array(D.$sources, function($key, $root) {
        $root = path.resolve($root);
        D.is_array(D.getDirectories($root), function($key, $project) {
          try {
            $_roots[$project] = path.join($root, $project);
          } catch (e) {
            console.log(e);
          }
        }, false);
      }, false);
      return $_roots;
    },
    initTaskName: function($project, $package, $template, $taskType) {
      var $_name = '';
      $_name = Array($project, $package, $template).join('__');
      if( typeof $taskType != 'undefined' && typeof $taskType == 'string' ) {
        $_name = Array($project, $package, $template, $taskType).join('__');
      }
      $_name = $_name.replaceAll('\\', '/');
      return $_name;
    },
    initTaskAutoComplete: function($path, $project, $projectDir, $callback) {
      if(typeof $projectDir == 'undefined') {
        $callback = $projectDir;
        $projectDir = $project;
      }
      var $paths = new Array();
      if(typeof $path == 'string' || $path instanceof String) {
        var $projectPath = $path.replaceAll('PROJECT', $projectDir);
        if($projectPath.indexOf('PACKAGE') >= 0) {
          D.is_array(D.getDirectories( path.resolve($projectPath.split('PACKAGE')[0]) ), function($key, $package) {
            var $packagePath = $projectPath.replaceAll('PACKAGE', $package);
            D.is_array(D.getDirectories( path.resolve($packagePath.split('TEMPLATE')[0]) ), function($key, $template) {
              var $templatePath = $packagePath.replaceAll('TEMPLATE', $template);
              D.is_file( path.resolve($templatePath), function($templatePath) {
                try {
                  $paths[D.initTaskName($project, $package, $template)] = $templatePath;
                  if(typeof $callback == 'function') {
                    $callback($templatePath);
                  }
                } catch (e) {
                  console.log(e);
                }
              });
            }, false);
          }, false);
        }
        return $paths;
      } else if( Object.prototype.toString.call( $path ) === '[object Array]' ||
        typeof $path == 'object' || $path instanceof Object ) {
        var $_app_key = 0;
        if( D.has_length($path) > 0 && typeof $path.src != 'undefined' && ($_app_key = D.has_file($path.src, 'app.js')) >= 0 ) {
          var $projectPath = $path.src[$_app_key].replaceAll('PROJECT', $projectDir);
          if($projectPath.indexOf('PACKAGE') >= 0) {
            D.is_array(D.getDirectories( path.resolve($projectPath.split('PACKAGE')[0])), function($key, $package) {
              var $packagePath = $projectPath.replaceAll('PACKAGE', $package);
              D.is_array(D.getDirectories( path.resolve($packagePath.split('TEMPLATE')[0])), function($key, $template) {
                var $templatePath = $packagePath.replaceAll('TEMPLATE', $template);
                D.is_file( path.resolve($templatePath), function($templatePath) {
                  try {
                    if(!$paths[D.initTaskName($project, $package, $template)]) {
                      $paths[D.initTaskName($project, $package, $template)] = {};
                    }
                    if(!$paths[D.initTaskName($project, $package, $template)].src) {
                      $paths[D.initTaskName($project, $package, $template)].src = new Array();
                    }
                    $paths[D.initTaskName($project, $package, $template)].src.push($templatePath);
                    // $paths[D.initTaskName($project, $package, $template)].src.unshift($templatePath);
                    D.is_array($path.src, function($key, $src) {
                      var $srcPath = $src.replaceAll('PROJECT', $projectDir);
                      $srcPath = $srcPath.replaceAll('PACKAGE', $package);
                      $srcPath = $srcPath.replaceAll('TEMPLATE', $template);
                      $srcPath = path.resolve($srcPath);
                      if(!$paths[D.initTaskName($project, $package, $template)]) {
                        $paths[D.initTaskName($project, $package, $template)] = {};
                      }
                      if(!$paths[D.initTaskName($project, $package, $template)].src) {
                        $paths[D.initTaskName($project, $package, $template)].src = new Array();
                      }
                      D.is_file($srcPath, function($srcPath) {
                        if( $paths[D.initTaskName($project, $package, $template)].src.indexOf($srcPath) < 0 ) {
                          $paths[D.initTaskName($project, $package, $template)].src.push($srcPath);
                          // $paths[D.initTaskName($project, $package, $template)].src.unshift($srcPath);
                        }
                      });
                    }, false);

                    var $templateFolder = path.dirname($templatePath);
                    D.is_array(D.getFiles( $templateFolder ), function($key, $src) {
                      var $srcPath = path.resolve( path.join(path.resolve($templateFolder), $src) );
                      if(!$paths[D.initTaskName($project, $package, $template)]) {
                        $paths[D.initTaskName($project, $package, $template)] = {};
                      }
                      if(!$paths[D.initTaskName($project, $package, $template)].src) {
                        $paths[D.initTaskName($project, $package, $template)].src = new Array();
                      }
                      D.is_file($srcPath, function($srcPath) {
                        if( $paths[D.initTaskName($project, $package, $template)].src.indexOf($srcPath) < 0 ) {
                          $paths[D.initTaskName($project, $package, $template)].src.unshift($srcPath);
                        }
                      });
                    }, false);

                    var $destPath = $path.dest.replaceAll('PROJECT', $projectDir);
                    $destPath = $destPath.replaceAll('PACKAGE', $package);
                    $destPath = $destPath.replaceAll('TEMPLATE', $template);
                    $destPath = path.resolve($destPath);
                    $paths[D.initTaskName($project, $package, $template)].dest = $destPath;
                    if(typeof $callback == 'function') {
                      $callback($templatePath);
                    }
                  } catch (e) {
                    console.log(e);
                  }
                });
              }, false);
            }, false);
          }
          return $paths;
        }
      }
    },
    initTaskAppendWatch: function($framework, $taskType, $project, $projectDir, $taskName, $srcName, $taskFor) {
      if( !$initConfig.watch[D.initTaskName($project, $taskName, $srcName, $taskType)] ) {
        try {
          var $project = $srcName.split('__')[0];
          var $package = $srcName.split('__')[1];
          var $template = $srcName.split('__')[2];
          var $watchPaths = new Array();
          D.is_array($framework.watch[$taskType], function($key, $watchPath) {
            try {
              $watchPath = $watchPath.replaceAll('PROJECT', $projectDir);
              $watchPath = $watchPath.replaceAll('PACKAGE', $package);
              $watchPath = $watchPath.replaceAll('TEMPLATE', $template);
              if( $watchPath.indexOf('!') == 0 ) {
                $watchPath = $watchPath.replaceAll('!', '');
                $watchPath = path.resolve($watchPath);
                $watchPath = '!' + $watchPath;
              } else {
                $watchPath = path.resolve($watchPath);
              }
              $watchPaths.push($watchPath);
            } catch (e) {
              console.log(e);
            }
          }, false);
          $initConfig.watch[D.initTaskName($project, $taskName, $srcName, $taskType)] = {
            files: [ $watchPaths ],
            tasks: new Array(),
          };
        } catch (e) {
          console.log(e);
        }
      }
      try {
        $initConfig.watch[D.initTaskName($project, $taskName, $srcName, $taskType)].tasks.push(
          $taskFor + ":" + D.initTaskName($project, $taskName, $srcName)
        );
      } catch (e) {
        console.log(e);
      }
    },
    initTaskLess: function($framework, $source, $project, $projectDir) {
      D.is_array($source, function($taskName, $path) {
        var $srcs = D.initTaskAutoComplete($path, $project, $projectDir);
        D.is_array($srcs, function($srcName, $srcPath) {
          try {
            var $cssPath = $srcPath.replaceAll('less', 'css');
            $initConfig.less[D.initTaskName($project, $taskName, $srcName)] = {
              files: {
                [$cssPath]: [ $srcPath ],
              },
            };
            D.initTaskAppendWatch($framework, 'less', $project, $projectDir, $taskName, $srcName, 'less');
          } catch (e) {
            console.log(e);
          }
        }, false);
      }, false);
    },
    initTaskAutoprefixer: function($framework, $source, $project, $projectDir) {
      D.is_array($source, function($taskName, $path) {
        var $srcs = D.initTaskAutoComplete($path, $project, $projectDir);
        D.is_array($srcs, function($srcName, $srcPath) {
          try {
            $initConfig.autoprefixer[D.initTaskName($project, $taskName, $srcName)] = {
              files: {
                [$srcPath]: [ $srcPath ],
              },
            };
            D.initTaskAppendWatch($framework, 'less', $project, $projectDir, $taskName, $srcName, 'autoprefixer');
            D.initTaskAppendWatch($framework, 'css', $project, $projectDir, $taskName, $srcName, 'autoprefixer');
          } catch (e) {
            console.log(e);
          }
        }, false);
      }, false);
    },
    initTaskCssmin: function($framework, $source, $project, $projectDir) {
      D.is_array($source, function($taskName, $path) {
        var $srcs = D.initTaskAutoComplete($path, $project, $projectDir);
        D.is_array($srcs, function($srcName, $srcPath) {
          try {
            var $cssPath = $srcPath.replaceAll('app.min.css', 'app.css');
            $cssPath = $cssPath.replaceAll('bootstrap.min.css', 'bootstrap.css');
            if($cssPath != $srcPath) {
              $initConfig.cssmin[D.initTaskName($project, $taskName, $srcName)] = {
                files: {
                  [$srcPath]: [ $cssPath ],
                }
              };
              D.initTaskAppendWatch($framework, 'less', $project, $projectDir, $taskName, $srcName, 'cssmin');
              D.initTaskAppendWatch($framework, 'css', $project, $projectDir, $taskName, $srcName, 'cssmin');
            }
          } catch (e) {
            console.log(e);
          }
        }, false);
      }, false);
    },
    initTaskConcat: function($framework, $source, $project, $projectDir) {
      D.is_array($source, function($taskName, $path) {
        var $srcs = D.initTaskAutoComplete($path, $project, $projectDir);
        D.is_array($srcs, function($srcName, $srcPath) {
          try {
            $initConfig.concat[D.initTaskName($project, $taskName, $srcName)] = $srcPath;
            D.initTaskAppendWatch($framework, 'js', $project, $projectDir, $taskName, $srcName, 'concat');
          } catch (e) {
            console.log(e);
          }
        }, false);
      }, false);
    },
    initTaskNgAnnotate: function($framework, $source, $project, $projectDir) {
      D.is_array($source, function($taskName, $path) {
        var $srcs = D.initTaskAutoComplete($path, $project, $projectDir);
        D.is_array($srcs, function($srcName, $srcPath) {
          try {
            $initConfig.ngAnnotate[D.initTaskName($project, $taskName, $srcName)] = {
              files: {
                [$srcPath]: [ $srcPath ],
              }
            };
            D.initTaskAppendWatch($framework, 'js', $project, $projectDir, $taskName, $srcName, 'ngAnnotate');
          } catch (e) {
            console.log(e);
          }
        }, false);
      }, false);
    },
    initTaskUglify: function($framework, $source, $project, $projectDir) {
      D.is_array($source, function($taskName, $path) {
        var $srcs = D.initTaskAutoComplete($path.replaceAll('.min.js', '.js'), $project, $projectDir, function($templatePath) {
        });
        D.is_array($srcs, function($srcName, $srcPath) {
          try {
            var $jsPath = $srcPath.replaceAll('app.js', 'app.min.js');
            $jsPath = $jsPath.replaceAll('bootstrap.js', 'bootstrap.min.js');
            if($jsPath != $srcPath) {
              $initConfig.uglify[D.initTaskName($project, $taskName, $srcName)] = {
                files: {
                  [$jsPath]: [ $srcPath ],
                }
              };
              D.initTaskAppendWatch($framework, 'js', $project, $projectDir, $taskName, $srcName, 'uglify');
            }
          } catch (e) {
            console.log(e);
          }
        }, false);
      }, false);
    },
    initTask: function($framework, $task, $source, $project, $projectDir) {
      try {
        var _taskType = 'initTask' + $task.toCapitalize();
        if(typeof D[_taskType] === 'function') {
          D.is_dir($projectDir, function($projectDir) {
            D[_taskType]($framework, $source, $project, $projectDir);
          });
        }
      } catch (e) {
        console.log(e);
      }
    },
    initFramework: function($framework, $project, $projectDir) {
      D.is_array($framework, function($task, $source) {
        try {
          D.initTask($framework, $task, $source, $project, $projectDir);
        } catch (e) {
          console.log(e);
        }
      }, false);
    },
    initFrameworks: function($project, $projectDir) {
      D.is_dir($projectDir, function() {
        D.is_array($frameworks, function($key, $framework) {
          try {
            D.initFramework($framework, $project, $projectDir);
          } catch (e) {
            console.log(e);
          }
        }, false);
      });
    },
    init: function() {
      var $projects = D.projects();
      D.is_array($projects, function($project, $projectDir) {
        D.is_dir($projectDir, function($projectDir) {
          try {
            D.initFrameworks($project, $projectDir);
          } catch (e) {
            console.log(e);
          }
        });
      }, false);
      try {
        fs.writeFile(path.join(path.resolve(__dirname), 'Gruntapps2.json'), JSON.stringify($initConfig, null, 2), function(err) {
          if(err) {
            return console.log(err);
          }
        });
      } catch (e) {
        console.log(e);
      }
      return $initConfig;
    },
  };

  $initConfig = D.init();

  // var $initConfig = grunt.file.readJSON('Gruntapps.json');
  $initConfig.pkg = grunt.file.readJSON('package.json');

  grunt.initConfig($initConfig);

  grunt.registerTask('default', 'Run develop', function (target) {

    grunt.log.writeln('Process plugins...'['green'].italic);
    grunt.task.run([
      'watch'
    ]);

  });

}
