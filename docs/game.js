
var Module;

if (typeof Module === 'undefined') Module = eval('(function() { try { return Module || {} } catch(e) { return {} } })()');

if (!Module.expectedDataFileDownloads) {
  Module.expectedDataFileDownloads = 0;
  Module.finishedDataFileDownloads = 0;
}
Module.expectedDataFileDownloads++;
(function() {
 var loadPackage = function(metadata) {

  var PACKAGE_PATH;
  if (typeof window === 'object') {
    PACKAGE_PATH = window['encodeURIComponent'](window.location.pathname.toString().substring(0, window.location.pathname.toString().lastIndexOf('/')) + '/');
  } else if (typeof location !== 'undefined') {
      // worker
      PACKAGE_PATH = encodeURIComponent(location.pathname.toString().substring(0, location.pathname.toString().lastIndexOf('/')) + '/');
    } else {
      throw 'using preloaded data can only be done on a web page or in a web worker';
    }
    var PACKAGE_NAME = 'game.data';
    var REMOTE_PACKAGE_BASE = 'game.data';
    if (typeof Module['locateFilePackage'] === 'function' && !Module['locateFile']) {
      Module['locateFile'] = Module['locateFilePackage'];
      Module.printErr('warning: you defined Module.locateFilePackage, that has been renamed to Module.locateFile (using your locateFilePackage for now)');
    }
    var REMOTE_PACKAGE_NAME = typeof Module['locateFile'] === 'function' ?
    Module['locateFile'](REMOTE_PACKAGE_BASE) :
    ((Module['filePackagePrefixURL'] || '') + REMOTE_PACKAGE_BASE);

    var REMOTE_PACKAGE_SIZE = metadata.remote_package_size;
    var PACKAGE_UUID = metadata.package_uuid;

    function fetchRemotePackage(packageName, packageSize, callback, errback) {
      var xhr = new XMLHttpRequest();
      xhr.open('GET', packageName, true);
      xhr.responseType = 'arraybuffer';
      xhr.onprogress = function(event) {
        var url = packageName;
        var size = packageSize;
        if (event.total) size = event.total;
        if (event.loaded) {
          if (!xhr.addedTotal) {
            xhr.addedTotal = true;
            if (!Module.dataFileDownloads) Module.dataFileDownloads = {};
            Module.dataFileDownloads[url] = {
              loaded: event.loaded,
              total: size
            };
          } else {
            Module.dataFileDownloads[url].loaded = event.loaded;
          }
          var total = 0;
          var loaded = 0;
          var num = 0;
          for (var download in Module.dataFileDownloads) {
            var data = Module.dataFileDownloads[download];
            total += data.total;
            loaded += data.loaded;
            num++;
          }
          total = Math.ceil(total * Module.expectedDataFileDownloads/num);
          if (Module['setStatus']) Module['setStatus']('Downloading data... (' + loaded + '/' + total + ')');
        } else if (!Module.dataFileDownloads) {
          if (Module['setStatus']) Module['setStatus']('Downloading data...');
        }
      };
      xhr.onerror = function(event) {
        throw new Error("NetworkError for: " + packageName);
      }
      xhr.onload = function(event) {
        if (xhr.status == 200 || xhr.status == 304 || xhr.status == 206 || (xhr.status == 0 && xhr.response)) { // file URLs can return 0
          var packageData = xhr.response;
          callback(packageData);
        } else {
          throw new Error(xhr.statusText + " : " + xhr.responseURL);
        }
      };
      xhr.send(null);
    };

    function handleError(error) {
      console.error('package error:', error);
    };

    function runWithFS() {

      function assert(check, msg) {
        if (!check) throw msg + new Error().stack;
      }
      Module['FS_createPath']('/', 'TESound', true, true);
      Module['FS_createPath']('/', 'debugger', true, true);
      Module['FS_createPath']('/debugger', 'embed', true, true);
      Module['FS_createPath']('/debugger', 'test', true, true);
      Module['FS_createPath']('/', 'game_objects', true, true);
      Module['FS_createPath']('/', 'resolution_solution', true, true);
      Module['FS_createPath']('/resolution_solution', 'demo', true, true);
      Module['FS_createPath']('/resolution_solution', 'examples', true, true);
      Module['FS_createPath']('/resolution_solution/examples', 'basic_setup_with_canvas', true, true);
      Module['FS_createPath']('/resolution_solution/examples', 'basic_setup_with_scissor', true, true);
      Module['FS_createPath']('/resolution_solution/examples', 'check_if_cursor_inside_game_zone', true, true);
      Module['FS_createPath']('/resolution_solution/examples', 'crispy_ui', true, true);
      Module['FS_createPath']('/resolution_solution/examples', 'cursor_that_never_leaves_game_zone', true, true);
      Module['FS_createPath']('/resolution_solution/examples', 'custom_black_bars', true, true);
      Module['FS_createPath']('/resolution_solution/examples', 'gamera', true, true);
      Module['FS_createPath']('/resolution_solution/examples', 'hump_camera', true, true);
      Module['FS_createPath']('/resolution_solution', 'history', true, true);
      Module['FS_createPath']('/', 'resources', true, true);
      Module['FS_createPath']('/resources', 'audio', true, true);
      Module['FS_createPath']('/resources/audio', 'Laser', true, true);
      Module['FS_createPath']('/resources', 'backgrounds', true, true);
      Module['FS_createPath']('/resources', 'fonts', true, true);
      Module['FS_createPath']('/resources', 'game_object_data', true, true);
      Module['FS_createPath']('/resources', 'sprites', true, true);
      Module['FS_createPath']('/resources/sprites', 'Damage', true, true);
      Module['FS_createPath']('/resources/sprites', 'Effects', true, true);
      Module['FS_createPath']('/resources/sprites', 'Enemies', true, true);
      Module['FS_createPath']('/resources/sprites', 'Lasers', true, true);
      Module['FS_createPath']('/resources/sprites', 'Meteors', true, true);
      Module['FS_createPath']('/resources/sprites', 'Parts', true, true);
      Module['FS_createPath']('/resources/sprites', 'Power-ups', true, true);
      Module['FS_createPath']('/resources/sprites', 'UI', true, true);
      Module['FS_createPath']('/', 'world', true, true);

      function DataRequest(start, end, crunched, audio) {
        this.start = start;
        this.end = end;
        this.crunched = crunched;
        this.audio = audio;
      }
      DataRequest.prototype = {
        requests: {},
        open: function(mode, name) {
          this.name = name;
          this.requests[name] = this;
          Module['addRunDependency']('fp ' + this.name);
        },
        send: function() {},
        onload: function() {
          var byteArray = this.byteArray.subarray(this.start, this.end);

          this.finish(byteArray);

        },
        finish: function(byteArray) {
          var that = this;

        Module['FS_createDataFile'](this.name, null, byteArray, true, true, true); // canOwn this data in the filesystem, it is a slide into the heap that will never change
        Module['removeRunDependency']('fp ' + that.name);

        this.requests[this.name] = null;
      }
    };

    var files = metadata.files;
    for (i = 0; i < files.length; ++i) {
      new DataRequest(files[i].start, files[i].end, files[i].crunched, files[i].audio).open('GET', files[i].filename);
    }


    var indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;
    var IDB_RO = "readonly";
    var IDB_RW = "readwrite";
    var DB_NAME = "EM_PRELOAD_CACHE";
    var DB_VERSION = 1;
    var METADATA_STORE_NAME = 'METADATA';
    var PACKAGE_STORE_NAME = 'PACKAGES';
    function openDatabase(callback, errback) {
      try {
        var openRequest = indexedDB.open(DB_NAME, DB_VERSION);
      } catch (e) {
        return errback(e);
      }
      openRequest.onupgradeneeded = function(event) {
        var db = event.target.result;

        if(db.objectStoreNames.contains(PACKAGE_STORE_NAME)) {
          db.deleteObjectStore(PACKAGE_STORE_NAME);
        }
        var packages = db.createObjectStore(PACKAGE_STORE_NAME);

        if(db.objectStoreNames.contains(METADATA_STORE_NAME)) {
          db.deleteObjectStore(METADATA_STORE_NAME);
        }
        var metadata = db.createObjectStore(METADATA_STORE_NAME);
      };
      openRequest.onsuccess = function(event) {
        var db = event.target.result;
        callback(db);
      };
      openRequest.onerror = function(error) {
        errback(error);
      };
    };

    /* Check if there's a cached package, and if so whether it's the latest available */
    function checkCachedPackage(db, packageName, callback, errback) {
      var transaction = db.transaction([METADATA_STORE_NAME], IDB_RO);
      var metadata = transaction.objectStore(METADATA_STORE_NAME);

      var getRequest = metadata.get("metadata/" + packageName);
      getRequest.onsuccess = function(event) {
        var result = event.target.result;
        if (!result) {
          return callback(false);
        } else {
          return callback(PACKAGE_UUID === result.uuid);
        }
      };
      getRequest.onerror = function(error) {
        errback(error);
      };
    };

    function fetchCachedPackage(db, packageName, callback, errback) {
      var transaction = db.transaction([PACKAGE_STORE_NAME], IDB_RO);
      var packages = transaction.objectStore(PACKAGE_STORE_NAME);

      var getRequest = packages.get("package/" + packageName);
      getRequest.onsuccess = function(event) {
        var result = event.target.result;
        callback(result);
      };
      getRequest.onerror = function(error) {
        errback(error);
      };
    };

    function cacheRemotePackage(db, packageName, packageData, packageMeta, callback, errback) {
      var transaction_packages = db.transaction([PACKAGE_STORE_NAME], IDB_RW);
      var packages = transaction_packages.objectStore(PACKAGE_STORE_NAME);

      var putPackageRequest = packages.put(packageData, "package/" + packageName);
      putPackageRequest.onsuccess = function(event) {
        var transaction_metadata = db.transaction([METADATA_STORE_NAME], IDB_RW);
        var metadata = transaction_metadata.objectStore(METADATA_STORE_NAME);
        var putMetadataRequest = metadata.put(packageMeta, "metadata/" + packageName);
        putMetadataRequest.onsuccess = function(event) {
          callback(packageData);
        };
        putMetadataRequest.onerror = function(error) {
          errback(error);
        };
      };
      putPackageRequest.onerror = function(error) {
        errback(error);
      };
    };

    function processPackageData(arrayBuffer) {
      Module.finishedDataFileDownloads++;
      assert(arrayBuffer, 'Loading data file failed.');
      assert(arrayBuffer instanceof ArrayBuffer, 'bad input to processPackageData');
      var byteArray = new Uint8Array(arrayBuffer);
      var curr;

        // copy the entire loaded file into a spot in the heap. Files will refer to slices in that. They cannot be freed though
        // (we may be allocating before malloc is ready, during startup).
        if (Module['SPLIT_MEMORY']) Module.printErr('warning: you should run the file packager with --no-heap-copy when SPLIT_MEMORY is used, otherwise copying into the heap may fail due to the splitting');
        var ptr = Module['getMemory'](byteArray.length);
        Module['HEAPU8'].set(byteArray, ptr);
        DataRequest.prototype.byteArray = Module['HEAPU8'].subarray(ptr, ptr+byteArray.length);

        var files = metadata.files;
        for (i = 0; i < files.length; ++i) {
          DataRequest.prototype.requests[files[i].filename].onload();
        }
        Module['removeRunDependency']('datafile_game.data');

      };
      Module['addRunDependency']('datafile_game.data');

      if (!Module.preloadResults) Module.preloadResults = {};

      function preloadFallback(error) {
        console.error(error);
        console.error('falling back to default preload behavior');
        fetchRemotePackage(REMOTE_PACKAGE_NAME, REMOTE_PACKAGE_SIZE, processPackageData, handleError);
      };

      openDatabase(
        function(db) {
          checkCachedPackage(db, PACKAGE_PATH + PACKAGE_NAME,
            function(useCached) {
              Module.preloadResults[PACKAGE_NAME] = {fromCache: useCached};
              if (useCached) {
                console.info('loading ' + PACKAGE_NAME + ' from cache');
                fetchCachedPackage(db, PACKAGE_PATH + PACKAGE_NAME, processPackageData, preloadFallback);
              } else {
                console.info('loading ' + PACKAGE_NAME + ' from remote');
                fetchRemotePackage(REMOTE_PACKAGE_NAME, REMOTE_PACKAGE_SIZE,
                  function(packageData) {
                    cacheRemotePackage(db, PACKAGE_PATH + PACKAGE_NAME, packageData, {uuid:PACKAGE_UUID}, processPackageData,
                      function(error) {
                        console.error(error);
                        processPackageData(packageData);
                      });
                  }
                  , preloadFallback);
              }
            }
            , preloadFallback);
        }
        , preloadFallback);

      if (Module['setStatus']) Module['setStatus']('Downloading...');

    }
    if (Module['calledRun']) {
      runWithFS();
    } else {
      if (!Module['preRun']) Module['preRun'] = [];
      Module["preRun"].push(runWithFS); // FS is not initialized yet, wait for it
    }

  }
  loadPackage({"package_uuid":"23e582e2-b871-48c4-97da-656390af4e0b","remote_package_size":10425229,"files":[{"filename":"/TESound/.git","crunched":0,"start":0,"end":35,"audio":false},{"filename":"/TESound/LICENSE.md","crunched":0,"start":35,"end":940,"audio":false},{"filename":"/TESound/README.md","crunched":0,"start":940,"end":1551,"audio":false},{"filename":"/TESound/tesound.lua","crunched":0,"start":1551,"end":10205,"audio":false},{"filename":"/animation.lua","crunched":0,"start":10205,"end":15181,"audio":false},{"filename":"/debugger/.git","crunched":0,"start":15181,"end":15217,"audio":false},{"filename":"/debugger/.gitignore","crunched":0,"start":15217,"end":15249,"audio":false},{"filename":"/debugger/README.md","crunched":0,"start":15249,"end":23134,"audio":false},{"filename":"/debugger/debugger-lua-scm-1.rockspec","crunched":0,"start":23134,"end":24176,"audio":false},{"filename":"/debugger/debugger.lua","crunched":0,"start":24176,"end":45358,"audio":false},{"filename":"/debugger/embed/debugger_lua.c.lua","crunched":0,"start":45358,"end":49002,"audio":false},{"filename":"/debugger/embed/debugger_lua.h","crunched":0,"start":49002,"end":52444,"audio":false},{"filename":"/debugger/test/run_tests.sh","crunched":0,"start":52444,"end":52524,"audio":false},{"filename":"/debugger/test/test.lua","crunched":0,"start":52524,"end":53914,"audio":false},{"filename":"/debugger/test/test_util.lua","crunched":0,"start":53914,"end":60686,"audio":false},{"filename":"/debugger/tutorial.lua","crunched":0,"start":60686,"end":67867,"audio":false},{"filename":"/game_objects/game_objects.lua","crunched":0,"start":67867,"end":72858,"audio":false},{"filename":"/game_objects/movement_profiles.lua","crunched":0,"start":72858,"end":75765,"audio":false},{"filename":"/game_objects/player.lua","crunched":0,"start":75765,"end":81789,"audio":false},{"filename":"/game_objects/powerups.lua","crunched":0,"start":81789,"end":82727,"audio":false},{"filename":"/game_objects/saucer.lua","crunched":0,"start":82727,"end":86304,"audio":false},{"filename":"/game_objects/shield.lua","crunched":0,"start":86304,"end":87859,"audio":false},{"filename":"/game_objects/spawn_profiles.lua","crunched":0,"start":87859,"end":91037,"audio":false},{"filename":"/game_objects/weapons.lua","crunched":0,"start":91037,"end":94300,"audio":false},{"filename":"/main.lua","crunched":0,"start":94300,"end":96601,"audio":false},{"filename":"/menu.lua","crunched":0,"start":96601,"end":99150,"audio":false},{"filename":"/resolution_solution/.git","crunched":0,"start":99150,"end":99197,"audio":false},{"filename":"/resolution_solution/.gitignore","crunched":0,"start":99197,"end":99240,"audio":false},{"filename":"/resolution_solution/LICENSE","crunched":0,"start":99240,"end":100451,"audio":false},{"filename":"/resolution_solution/README.md","crunched":0,"start":100451,"end":105559,"audio":false},{"filename":"/resolution_solution/demo/image.png","crunched":0,"start":105559,"end":136537,"audio":false},{"filename":"/resolution_solution/demo/main.lua","crunched":0,"start":136537,"end":142771,"audio":false},{"filename":"/resolution_solution/demo/resolution_solution.lua","crunched":0,"start":142771,"end":154177,"audio":false},{"filename":"/resolution_solution/demo.love","crunched":0,"start":154177,"end":185551,"audio":false},{"filename":"/resolution_solution/examples/basic_setup_with_canvas/image.png","crunched":0,"start":185551,"end":216486,"audio":false},{"filename":"/resolution_solution/examples/basic_setup_with_canvas/main.lua","crunched":0,"start":216486,"end":218743,"audio":false},{"filename":"/resolution_solution/examples/basic_setup_with_canvas/resolution_solution.lua","crunched":0,"start":218743,"end":230149,"audio":false},{"filename":"/resolution_solution/examples/basic_setup_with_scissor/image.png","crunched":0,"start":230149,"end":261084,"audio":false},{"filename":"/resolution_solution/examples/basic_setup_with_scissor/main.lua","crunched":0,"start":261084,"end":263287,"audio":false},{"filename":"/resolution_solution/examples/basic_setup_with_scissor/resolution_solution.lua","crunched":0,"start":263287,"end":274693,"audio":false},{"filename":"/resolution_solution/examples/check_if_cursor_inside_game_zone/image.png","crunched":0,"start":274693,"end":305628,"audio":false},{"filename":"/resolution_solution/examples/check_if_cursor_inside_game_zone/main.lua","crunched":0,"start":305628,"end":308498,"audio":false},{"filename":"/resolution_solution/examples/check_if_cursor_inside_game_zone/resolution_solution.lua","crunched":0,"start":308498,"end":319904,"audio":false},{"filename":"/resolution_solution/examples/crispy_ui/image.png","crunched":0,"start":319904,"end":350839,"audio":false},{"filename":"/resolution_solution/examples/crispy_ui/main.lua","crunched":0,"start":350839,"end":355546,"audio":false},{"filename":"/resolution_solution/examples/crispy_ui/resolution_solution.lua","crunched":0,"start":355546,"end":366952,"audio":false},{"filename":"/resolution_solution/examples/cursor_that_never_leaves_game_zone/cursor.png","crunched":0,"start":366952,"end":367579,"audio":false},{"filename":"/resolution_solution/examples/cursor_that_never_leaves_game_zone/image.png","crunched":0,"start":367579,"end":398514,"audio":false},{"filename":"/resolution_solution/examples/cursor_that_never_leaves_game_zone/main.lua","crunched":0,"start":398514,"end":401498,"audio":false},{"filename":"/resolution_solution/examples/cursor_that_never_leaves_game_zone/resolution_solution.lua","crunched":0,"start":401498,"end":412904,"audio":false},{"filename":"/resolution_solution/examples/custom_black_bars/image.png","crunched":0,"start":412904,"end":443839,"audio":false},{"filename":"/resolution_solution/examples/custom_black_bars/main.lua","crunched":0,"start":443839,"end":446881,"audio":false},{"filename":"/resolution_solution/examples/custom_black_bars/resolution_solution.lua","crunched":0,"start":446881,"end":458287,"audio":false},{"filename":"/resolution_solution/examples/gamera/gamera.lua","crunched":0,"start":458287,"end":464182,"audio":false},{"filename":"/resolution_solution/examples/gamera/image.png","crunched":0,"start":464182,"end":495117,"audio":false},{"filename":"/resolution_solution/examples/gamera/main.lua","crunched":0,"start":495117,"end":500838,"audio":false},{"filename":"/resolution_solution/examples/gamera/readme.md","crunched":0,"start":500838,"end":502185,"audio":false},{"filename":"/resolution_solution/examples/gamera/resolution_solution.lua","crunched":0,"start":502185,"end":513591,"audio":false},{"filename":"/resolution_solution/examples/hump_camera/camera.lua","crunched":0,"start":513591,"end":519658,"audio":false},{"filename":"/resolution_solution/examples/hump_camera/image.png","crunched":0,"start":519658,"end":550593,"audio":false},{"filename":"/resolution_solution/examples/hump_camera/main.lua","crunched":0,"start":550593,"end":555250,"audio":false},{"filename":"/resolution_solution/examples/hump_camera/readme.md","crunched":0,"start":555250,"end":556633,"audio":false},{"filename":"/resolution_solution/examples/hump_camera/resolution_solution.lua","crunched":0,"start":556633,"end":568039,"audio":false},{"filename":"/resolution_solution/history/readme.md","crunched":0,"start":568039,"end":568237,"audio":false},{"filename":"/resolution_solution/history/v1000.lua","crunched":0,"start":568237,"end":578011,"audio":false},{"filename":"/resolution_solution/history/v1001.lua","crunched":0,"start":578011,"end":590524,"audio":false},{"filename":"/resolution_solution/history/v1002.lua","crunched":0,"start":590524,"end":611773,"audio":false},{"filename":"/resolution_solution/history/v1003.lua","crunched":0,"start":611773,"end":633984,"audio":false},{"filename":"/resolution_solution/history/v1004.lua","crunched":0,"start":633984,"end":656963,"audio":false},{"filename":"/resolution_solution/history/v1005.lua","crunched":0,"start":656963,"end":681995,"audio":false},{"filename":"/resolution_solution/history/v1006.lua","crunched":0,"start":681995,"end":707629,"audio":false},{"filename":"/resolution_solution/history/v2000.lua","crunched":0,"start":707629,"end":743481,"audio":false},{"filename":"/resolution_solution/history/v2000_minified.lua","crunched":0,"start":743481,"end":752738,"audio":false},{"filename":"/resolution_solution/history/v2001.lua","crunched":0,"start":752738,"end":794022,"audio":false},{"filename":"/resolution_solution/history/v2001_minified.lua","crunched":0,"start":794022,"end":804624,"audio":false},{"filename":"/resolution_solution/history/v3000.lua","crunched":0,"start":804624,"end":815201,"audio":false},{"filename":"/resolution_solution/history/v3000.odt","crunched":0,"start":815201,"end":1229094,"audio":false},{"filename":"/resolution_solution/history/v3000.pdf","crunched":0,"start":1229094,"end":2062285,"audio":false},{"filename":"/resolution_solution/history/v3001.lua","crunched":0,"start":2062285,"end":2072798,"audio":false},{"filename":"/resolution_solution/history/v3001.odt","crunched":0,"start":2072798,"end":2487179,"audio":false},{"filename":"/resolution_solution/history/v3001.pdf","crunched":0,"start":2487179,"end":3273885,"audio":false},{"filename":"/resolution_solution/history/v3002.lua","crunched":0,"start":3273885,"end":3285137,"audio":false},{"filename":"/resolution_solution/history/v3002.odt","crunched":0,"start":3285137,"end":3701016,"audio":false},{"filename":"/resolution_solution/history/v3002.pdf","crunched":0,"start":3701016,"end":4519828,"audio":false},{"filename":"/resolution_solution/history/v3003.lua","crunched":0,"start":4519828,"end":4531234,"audio":false},{"filename":"/resolution_solution/history/v3003.odt","crunched":0,"start":4531234,"end":4948566,"audio":false},{"filename":"/resolution_solution/history/v3003.pdf","crunched":0,"start":4948566,"end":5795338,"audio":false},{"filename":"/resolution_solution/resolution_solution.lua","crunched":0,"start":5795338,"end":5806744,"audio":false},{"filename":"/resolution_solution/resolution_solution_documentation.odt","crunched":0,"start":5806744,"end":6224076,"audio":false},{"filename":"/resolution_solution/resolution_solution_documentation.pdf","crunched":0,"start":6224076,"end":7070848,"audio":false},{"filename":"/resources/audio/Laser/Laser_00.wav","crunched":0,"start":7070848,"end":7252584,"audio":true},{"filename":"/resources/audio/Laser/Laser_01.wav","crunched":0,"start":7252584,"end":7388452,"audio":true},{"filename":"/resources/audio/Laser/Laser_02.wav","crunched":0,"start":7388452,"end":7642988,"audio":true},{"filename":"/resources/audio/Laser/Laser_03.wav","crunched":0,"start":7642988,"end":7828508,"audio":true},{"filename":"/resources/audio/Laser/Laser_04.wav","crunched":0,"start":7828508,"end":8111076,"audio":true},{"filename":"/resources/audio/Laser/Laser_05.wav","crunched":0,"start":8111076,"end":8400556,"audio":true},{"filename":"/resources/audio/Laser/Laser_06.wav","crunched":0,"start":8400556,"end":8683064,"audio":true},{"filename":"/resources/audio/Laser/Laser_07.wav","crunched":0,"start":8683064,"end":8884028,"audio":true},{"filename":"/resources/audio/Laser/Laser_08.wav","crunched":0,"start":8884028,"end":9152004,"audio":true},{"filename":"/resources/audio/Laser/Laser_09.wav","crunched":0,"start":9152004,"end":9257936,"audio":true},{"filename":"/resources/audio/explosionCrunch_000.ogg","crunched":0,"start":9257936,"end":9286210,"audio":true},{"filename":"/resources/audio/explosionCrunch_001.ogg","crunched":0,"start":9286210,"end":9334126,"audio":true},{"filename":"/resources/audio/explosionCrunch_002.ogg","crunched":0,"start":9334126,"end":9382033,"audio":true},{"filename":"/resources/audio/explosionCrunch_003.ogg","crunched":0,"start":9382033,"end":9436857,"audio":true},{"filename":"/resources/audio/explosionCrunch_004.ogg","crunched":0,"start":9436857,"end":9516107,"audio":true},{"filename":"/resources/audio/forceField_000.ogg","crunched":0,"start":9516107,"end":9541779,"audio":true},{"filename":"/resources/audio/forceField_001.ogg","crunched":0,"start":9541779,"end":9570726,"audio":true},{"filename":"/resources/audio/forceField_002.ogg","crunched":0,"start":9570726,"end":9598373,"audio":true},{"filename":"/resources/audio/forceField_003.ogg","crunched":0,"start":9598373,"end":9622311,"audio":true},{"filename":"/resources/audio/forceField_004.ogg","crunched":0,"start":9622311,"end":9649196,"audio":true},{"filename":"/resources/audio/impactMetal_000.ogg","crunched":0,"start":9649196,"end":9664687,"audio":true},{"filename":"/resources/audio/impactMetal_001.ogg","crunched":0,"start":9664687,"end":9679992,"audio":true},{"filename":"/resources/audio/impactMetal_002.ogg","crunched":0,"start":9679992,"end":9692700,"audio":true},{"filename":"/resources/audio/impactMetal_003.ogg","crunched":0,"start":9692700,"end":9710003,"audio":true},{"filename":"/resources/audio/impactMetal_004.ogg","crunched":0,"start":9710003,"end":9721293,"audio":true},{"filename":"/resources/audio/laserLarge_000.ogg","crunched":0,"start":9721293,"end":9746859,"audio":true},{"filename":"/resources/audio/laserLarge_001.ogg","crunched":0,"start":9746859,"end":9773079,"audio":true},{"filename":"/resources/audio/laserLarge_002.ogg","crunched":0,"start":9773079,"end":9800519,"audio":true},{"filename":"/resources/audio/laserLarge_003.ogg","crunched":0,"start":9800519,"end":9826623,"audio":true},{"filename":"/resources/audio/laserLarge_004.ogg","crunched":0,"start":9826623,"end":9852906,"audio":true},{"filename":"/resources/audio/laserRetro_000.ogg","crunched":0,"start":9852906,"end":9865494,"audio":true},{"filename":"/resources/audio/laserRetro_001.ogg","crunched":0,"start":9865494,"end":9878226,"audio":true},{"filename":"/resources/audio/laserRetro_002.ogg","crunched":0,"start":9878226,"end":9891356,"audio":true},{"filename":"/resources/audio/laserRetro_003.ogg","crunched":0,"start":9891356,"end":9905627,"audio":true},{"filename":"/resources/audio/laserRetro_004.ogg","crunched":0,"start":9905627,"end":9918328,"audio":true},{"filename":"/resources/audio/laserSmall_000.ogg","crunched":0,"start":9918328,"end":9925614,"audio":true},{"filename":"/resources/audio/laserSmall_001.ogg","crunched":0,"start":9925614,"end":9933062,"audio":true},{"filename":"/resources/audio/laserSmall_002.ogg","crunched":0,"start":9933062,"end":9942035,"audio":true},{"filename":"/resources/audio/laserSmall_003.ogg","crunched":0,"start":9942035,"end":9950214,"audio":true},{"filename":"/resources/audio/laserSmall_004.ogg","crunched":0,"start":9950214,"end":9958846,"audio":true},{"filename":"/resources/audio/lowFrequency_explosion_000.ogg","crunched":0,"start":9958846,"end":9973163,"audio":true},{"filename":"/resources/audio/lowFrequency_explosion_001.ogg","crunched":0,"start":9973163,"end":9982571,"audio":true},{"filename":"/resources/audio/sounds.lua","crunched":0,"start":9982571,"end":9984393,"audio":false},{"filename":"/resources/backgrounds/black.png","crunched":0,"start":9984393,"end":9986908,"audio":false},{"filename":"/resources/backgrounds/blue.png","crunched":0,"start":9986908,"end":9989668,"audio":false},{"filename":"/resources/backgrounds/darkPurple.png","crunched":0,"start":9989668,"end":9992548,"audio":false},{"filename":"/resources/backgrounds/purple.png","crunched":0,"start":9992548,"end":9995680,"audio":false},{"filename":"/resources/fonts/fonts.lua","crunched":0,"start":9995680,"end":9996015,"audio":false},{"filename":"/resources/fonts/kenvector_future.ttf","crunched":0,"start":9996015,"end":10030151,"audio":false},{"filename":"/resources/fonts/kenvector_future_thin.ttf","crunched":0,"start":10030151,"end":10064251,"audio":false},{"filename":"/resources/game_object_data/lasers.lua","crunched":0,"start":10064251,"end":10066339,"audio":false},{"filename":"/resources/game_object_data/saucers.lua","crunched":0,"start":10066339,"end":10067999,"audio":false},{"filename":"/resources/game_object_data/worlds.lua","crunched":0,"start":10067999,"end":10068193,"audio":false},{"filename":"/resources/sprites/Damage/playerShip1_damage1.png","crunched":0,"start":10068193,"end":10069295,"audio":false},{"filename":"/resources/sprites/Damage/playerShip1_damage2.png","crunched":0,"start":10069295,"end":10070706,"audio":false},{"filename":"/resources/sprites/Damage/playerShip1_damage3.png","crunched":0,"start":10070706,"end":10072392,"audio":false},{"filename":"/resources/sprites/Damage/playerShip2_damage1.png","crunched":0,"start":10072392,"end":10073641,"audio":false},{"filename":"/resources/sprites/Damage/playerShip2_damage2.png","crunched":0,"start":10073641,"end":10075189,"audio":false},{"filename":"/resources/sprites/Damage/playerShip2_damage3.png","crunched":0,"start":10075189,"end":10076848,"audio":false},{"filename":"/resources/sprites/Damage/playerShip3_damage1.png","crunched":0,"start":10076848,"end":10077849,"audio":false},{"filename":"/resources/sprites/Damage/playerShip3_damage2.png","crunched":0,"start":10077849,"end":10079098,"audio":false},{"filename":"/resources/sprites/Damage/playerShip3_damage3.png","crunched":0,"start":10079098,"end":10080535,"audio":false},{"filename":"/resources/sprites/Effects/fire00.png","crunched":0,"start":10080535,"end":10080880,"audio":false},{"filename":"/resources/sprites/Effects/fire01.png","crunched":0,"start":10080880,"end":10081473,"audio":false},{"filename":"/resources/sprites/Effects/fire02.png","crunched":0,"start":10081473,"end":10082070,"audio":false},{"filename":"/resources/sprites/Effects/fire03.png","crunched":0,"start":10082070,"end":10082652,"audio":false},{"filename":"/resources/sprites/Effects/fire04.png","crunched":0,"start":10082652,"end":10083329,"audio":false},{"filename":"/resources/sprites/Effects/fire05.png","crunched":0,"start":10083329,"end":10084113,"audio":false},{"filename":"/resources/sprites/Effects/fire06.png","crunched":0,"start":10084113,"end":10084742,"audio":false},{"filename":"/resources/sprites/Effects/fire07.png","crunched":0,"start":10084742,"end":10085476,"audio":false},{"filename":"/resources/sprites/Effects/fire08.png","crunched":0,"start":10085476,"end":10085854,"audio":false},{"filename":"/resources/sprites/Effects/fire09.png","crunched":0,"start":10085854,"end":10086241,"audio":false},{"filename":"/resources/sprites/Effects/fire10.png","crunched":0,"start":10086241,"end":10086588,"audio":false},{"filename":"/resources/sprites/Effects/fire11.png","crunched":0,"start":10086588,"end":10087199,"audio":false},{"filename":"/resources/sprites/Effects/fire12.png","crunched":0,"start":10087199,"end":10087786,"audio":false},{"filename":"/resources/sprites/Effects/fire13.png","crunched":0,"start":10087786,"end":10088374,"audio":false},{"filename":"/resources/sprites/Effects/fire14.png","crunched":0,"start":10088374,"end":10089058,"audio":false},{"filename":"/resources/sprites/Effects/fire15.png","crunched":0,"start":10089058,"end":10089838,"audio":false},{"filename":"/resources/sprites/Effects/fire16.png","crunched":0,"start":10089838,"end":10090479,"audio":false},{"filename":"/resources/sprites/Effects/fire17.png","crunched":0,"start":10090479,"end":10091218,"audio":false},{"filename":"/resources/sprites/Effects/fire18.png","crunched":0,"start":10091218,"end":10091599,"audio":false},{"filename":"/resources/sprites/Effects/fire19.png","crunched":0,"start":10091599,"end":10091985,"audio":false},{"filename":"/resources/sprites/Effects/shield1.png","crunched":0,"start":10091985,"end":10093419,"audio":false},{"filename":"/resources/sprites/Effects/shield2.png","crunched":0,"start":10093419,"end":10095676,"audio":false},{"filename":"/resources/sprites/Effects/shield3.png","crunched":0,"start":10095676,"end":10099299,"audio":false},{"filename":"/resources/sprites/Effects/speed.png","crunched":0,"start":10099299,"end":10099607,"audio":false},{"filename":"/resources/sprites/Effects/star1.png","crunched":0,"start":10099607,"end":10099919,"audio":false},{"filename":"/resources/sprites/Effects/star2.png","crunched":0,"start":10099919,"end":10100264,"audio":false},{"filename":"/resources/sprites/Effects/star3.png","crunched":0,"start":10100264,"end":10100634,"audio":false},{"filename":"/resources/sprites/Enemies/enemyBlack1.png","crunched":0,"start":10100634,"end":10103653,"audio":false},{"filename":"/resources/sprites/Enemies/enemyBlack2.png","crunched":0,"start":10103653,"end":10106643,"audio":false},{"filename":"/resources/sprites/Enemies/enemyBlack3.png","crunched":0,"start":10106643,"end":10110191,"audio":false},{"filename":"/resources/sprites/Enemies/enemyBlack4.png","crunched":0,"start":10110191,"end":10112450,"audio":false},{"filename":"/resources/sprites/Enemies/enemyBlack5.png","crunched":0,"start":10112450,"end":10115161,"audio":false},{"filename":"/resources/sprites/Enemies/enemyBlue1.png","crunched":0,"start":10115161,"end":10118256,"audio":false},{"filename":"/resources/sprites/Enemies/enemyBlue2.png","crunched":0,"start":10118256,"end":10121315,"audio":false},{"filename":"/resources/sprites/Enemies/enemyBlue3.png","crunched":0,"start":10121315,"end":10124934,"audio":false},{"filename":"/resources/sprites/Enemies/enemyBlue4.png","crunched":0,"start":10124934,"end":10127209,"audio":false},{"filename":"/resources/sprites/Enemies/enemyBlue5.png","crunched":0,"start":10127209,"end":10129929,"audio":false},{"filename":"/resources/sprites/Enemies/enemyGreen1.png","crunched":0,"start":10129929,"end":10133035,"audio":false},{"filename":"/resources/sprites/Enemies/enemyGreen2.png","crunched":0,"start":10133035,"end":10136094,"audio":false},{"filename":"/resources/sprites/Enemies/enemyGreen3.png","crunched":0,"start":10136094,"end":10139703,"audio":false},{"filename":"/resources/sprites/Enemies/enemyGreen4.png","crunched":0,"start":10139703,"end":10141986,"audio":false},{"filename":"/resources/sprites/Enemies/enemyGreen5.png","crunched":0,"start":10141986,"end":10144710,"audio":false},{"filename":"/resources/sprites/Enemies/enemyRed1.png","crunched":0,"start":10144710,"end":10147806,"audio":false},{"filename":"/resources/sprites/Enemies/enemyRed2.png","crunched":0,"start":10147806,"end":10150861,"audio":false},{"filename":"/resources/sprites/Enemies/enemyRed3.png","crunched":0,"start":10150861,"end":10154476,"audio":false},{"filename":"/resources/sprites/Enemies/enemyRed4.png","crunched":0,"start":10154476,"end":10156755,"audio":false},{"filename":"/resources/sprites/Enemies/enemyRed5.png","crunched":0,"start":10156755,"end":10159488,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue01.png","crunched":0,"start":10159488,"end":10160232,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue02.png","crunched":0,"start":10160232,"end":10160550,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue03.png","crunched":0,"start":10160550,"end":10160824,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue04.png","crunched":0,"start":10160824,"end":10161146,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue05.png","crunched":0,"start":10161146,"end":10161422,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue06.png","crunched":0,"start":10161422,"end":10162113,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue07.png","crunched":0,"start":10162113,"end":10162730,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue08.png","crunched":0,"start":10162730,"end":10163612,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue09.png","crunched":0,"start":10163612,"end":10164366,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue10.png","crunched":0,"start":10164366,"end":10165137,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue11.png","crunched":0,"start":10165137,"end":10165856,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue12.png","crunched":0,"start":10165856,"end":10166177,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue13.png","crunched":0,"start":10166177,"end":10166458,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue14.png","crunched":0,"start":10166458,"end":10166790,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue15.png","crunched":0,"start":10166790,"end":10167072,"audio":false},{"filename":"/resources/sprites/Lasers/laserBlue16.png","crunched":0,"start":10167072,"end":10167874,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen01.png","crunched":0,"start":10167874,"end":10168583,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen02.png","crunched":0,"start":10168583,"end":10168904,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen03.png","crunched":0,"start":10168904,"end":10169188,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen04.png","crunched":0,"start":10169188,"end":10169504,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen05.png","crunched":0,"start":10169504,"end":10169782,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen06.png","crunched":0,"start":10169782,"end":10170111,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen07.png","crunched":0,"start":10170111,"end":10170390,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen08.png","crunched":0,"start":10170390,"end":10170708,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen09.png","crunched":0,"start":10170708,"end":10170981,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen10.png","crunched":0,"start":10170981,"end":10171794,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen11.png","crunched":0,"start":10171794,"end":10172543,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen12.png","crunched":0,"start":10172543,"end":10173240,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen13.png","crunched":0,"start":10173240,"end":10173861,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen14.png","crunched":0,"start":10173861,"end":10174751,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen15.png","crunched":0,"start":10174751,"end":10175512,"audio":false},{"filename":"/resources/sprites/Lasers/laserGreen16.png","crunched":0,"start":10175512,"end":10176284,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed01.png","crunched":0,"start":10176284,"end":10177019,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed02.png","crunched":0,"start":10177019,"end":10177329,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed03.png","crunched":0,"start":10177329,"end":10177604,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed04.png","crunched":0,"start":10177604,"end":10177921,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed05.png","crunched":0,"start":10177921,"end":10178193,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed06.png","crunched":0,"start":10178193,"end":10178882,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed07.png","crunched":0,"start":10178882,"end":10179492,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed08.png","crunched":0,"start":10179492,"end":10180370,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed09.png","crunched":0,"start":10180370,"end":10181122,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed10.png","crunched":0,"start":10181122,"end":10181852,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed11.png","crunched":0,"start":10181852,"end":10182523,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed12.png","crunched":0,"start":10182523,"end":10182841,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed13.png","crunched":0,"start":10182841,"end":10183123,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed14.png","crunched":0,"start":10183123,"end":10183450,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed15.png","crunched":0,"start":10183450,"end":10183728,"audio":false},{"filename":"/resources/sprites/Lasers/laserRed16.png","crunched":0,"start":10183728,"end":10184531,"audio":false},{"filename":"/resources/sprites/Meteors/meteorBrown_big1.png","crunched":0,"start":10184531,"end":10186335,"audio":false},{"filename":"/resources/sprites/Meteors/meteorBrown_big2.png","crunched":0,"start":10186335,"end":10188658,"audio":false},{"filename":"/resources/sprites/Meteors/meteorBrown_big3.png","crunched":0,"start":10188658,"end":10190371,"audio":false},{"filename":"/resources/sprites/Meteors/meteorBrown_big4.png","crunched":0,"start":10190371,"end":10192361,"audio":false},{"filename":"/resources/sprites/Meteors/meteorBrown_med1.png","crunched":0,"start":10192361,"end":10193343,"audio":false},{"filename":"/resources/sprites/Meteors/meteorBrown_med3.png","crunched":0,"start":10193343,"end":10194224,"audio":false},{"filename":"/resources/sprites/Meteors/meteorBrown_small1.png","crunched":0,"start":10194224,"end":10194916,"audio":false},{"filename":"/resources/sprites/Meteors/meteorBrown_small2.png","crunched":0,"start":10194916,"end":10195583,"audio":false},{"filename":"/resources/sprites/Meteors/meteorBrown_tiny1.png","crunched":0,"start":10195583,"end":10196044,"audio":false},{"filename":"/resources/sprites/Meteors/meteorBrown_tiny2.png","crunched":0,"start":10196044,"end":10196415,"audio":false},{"filename":"/resources/sprites/Meteors/meteorGrey_big1.png","crunched":0,"start":10196415,"end":10198201,"audio":false},{"filename":"/resources/sprites/Meteors/meteorGrey_big2.png","crunched":0,"start":10198201,"end":10200511,"audio":false},{"filename":"/resources/sprites/Meteors/meteorGrey_big3.png","crunched":0,"start":10200511,"end":10202210,"audio":false},{"filename":"/resources/sprites/Meteors/meteorGrey_big4.png","crunched":0,"start":10202210,"end":10204177,"audio":false},{"filename":"/resources/sprites/Meteors/meteorGrey_med1.png","crunched":0,"start":10204177,"end":10205143,"audio":false},{"filename":"/resources/sprites/Meteors/meteorGrey_med2.png","crunched":0,"start":10205143,"end":10206007,"audio":false},{"filename":"/resources/sprites/Meteors/meteorGrey_small1.png","crunched":0,"start":10206007,"end":10206684,"audio":false},{"filename":"/resources/sprites/Meteors/meteorGrey_small2.png","crunched":0,"start":10206684,"end":10207341,"audio":false},{"filename":"/resources/sprites/Meteors/meteorGrey_tiny1.png","crunched":0,"start":10207341,"end":10207804,"audio":false},{"filename":"/resources/sprites/Meteors/meteorGrey_tiny2.png","crunched":0,"start":10207804,"end":10208176,"audio":false},{"filename":"/resources/sprites/Parts/beam0.png","crunched":0,"start":10208176,"end":10208717,"audio":false},{"filename":"/resources/sprites/Parts/beam1.png","crunched":0,"start":10208717,"end":10209183,"audio":false},{"filename":"/resources/sprites/Parts/beam2.png","crunched":0,"start":10209183,"end":10209780,"audio":false},{"filename":"/resources/sprites/Parts/beam3.png","crunched":0,"start":10209780,"end":10210336,"audio":false},{"filename":"/resources/sprites/Parts/beam4.png","crunched":0,"start":10210336,"end":10210760,"audio":false},{"filename":"/resources/sprites/Parts/beam5.png","crunched":0,"start":10210760,"end":10211482,"audio":false},{"filename":"/resources/sprites/Parts/beam6.png","crunched":0,"start":10211482,"end":10211979,"audio":false},{"filename":"/resources/sprites/Parts/beamLong1.png","crunched":0,"start":10211979,"end":10212326,"audio":false},{"filename":"/resources/sprites/Parts/beamLong2.png","crunched":0,"start":10212326,"end":10212923,"audio":false},{"filename":"/resources/sprites/Parts/cockpitBlue_0.png","crunched":0,"start":10212923,"end":10214477,"audio":false},{"filename":"/resources/sprites/Parts/cockpitBlue_1.png","crunched":0,"start":10214477,"end":10215129,"audio":false},{"filename":"/resources/sprites/Parts/cockpitBlue_2.png","crunched":0,"start":10215129,"end":10216230,"audio":false},{"filename":"/resources/sprites/Parts/cockpitBlue_3.png","crunched":0,"start":10216230,"end":10217291,"audio":false},{"filename":"/resources/sprites/Parts/cockpitBlue_4.png","crunched":0,"start":10217291,"end":10217998,"audio":false},{"filename":"/resources/sprites/Parts/cockpitBlue_5.png","crunched":0,"start":10217998,"end":10219184,"audio":false},{"filename":"/resources/sprites/Parts/cockpitBlue_6.png","crunched":0,"start":10219184,"end":10220311,"audio":false},{"filename":"/resources/sprites/Parts/cockpitBlue_7.png","crunched":0,"start":10220311,"end":10221418,"audio":false},{"filename":"/resources/sprites/Parts/cockpitGreen_0.png","crunched":0,"start":10221418,"end":10222970,"audio":false},{"filename":"/resources/sprites/Parts/cockpitGreen_1.png","crunched":0,"start":10222970,"end":10223627,"audio":false},{"filename":"/resources/sprites/Parts/cockpitGreen_2.png","crunched":0,"start":10223627,"end":10224738,"audio":false},{"filename":"/resources/sprites/Parts/cockpitGreen_3.png","crunched":0,"start":10224738,"end":10225799,"audio":false},{"filename":"/resources/sprites/Parts/cockpitGreen_4.png","crunched":0,"start":10225799,"end":10226509,"audio":false},{"filename":"/resources/sprites/Parts/cockpitGreen_5.png","crunched":0,"start":10226509,"end":10227647,"audio":false},{"filename":"/resources/sprites/Parts/cockpitGreen_6.png","crunched":0,"start":10227647,"end":10228768,"audio":false},{"filename":"/resources/sprites/Parts/cockpitGreen_7.png","crunched":0,"start":10228768,"end":10229958,"audio":false},{"filename":"/resources/sprites/Parts/cockpitRed_0.png","crunched":0,"start":10229958,"end":10231521,"audio":false},{"filename":"/resources/sprites/Parts/cockpitRed_1.png","crunched":0,"start":10231521,"end":10232183,"audio":false},{"filename":"/resources/sprites/Parts/cockpitRed_2.png","crunched":0,"start":10232183,"end":10233300,"audio":false},{"filename":"/resources/sprites/Parts/cockpitRed_3.png","crunched":0,"start":10233300,"end":10234372,"audio":false},{"filename":"/resources/sprites/Parts/cockpitRed_4.png","crunched":0,"start":10234372,"end":10235092,"audio":false},{"filename":"/resources/sprites/Parts/cockpitRed_5.png","crunched":0,"start":10235092,"end":10236293,"audio":false},{"filename":"/resources/sprites/Parts/cockpitRed_6.png","crunched":0,"start":10236293,"end":10237438,"audio":false},{"filename":"/resources/sprites/Parts/cockpitRed_7.png","crunched":0,"start":10237438,"end":10238561,"audio":false},{"filename":"/resources/sprites/Parts/cockpitYellow_0.png","crunched":0,"start":10238561,"end":10239205,"audio":false},{"filename":"/resources/sprites/Parts/cockpitYellow_1.png","crunched":0,"start":10239205,"end":10240272,"audio":false},{"filename":"/resources/sprites/Parts/cockpitYellow_2.png","crunched":0,"start":10240272,"end":10240996,"audio":false},{"filename":"/resources/sprites/Parts/cockpitYellow_3.png","crunched":0,"start":10240996,"end":10242188,"audio":false},{"filename":"/resources/sprites/Parts/cockpitYellow_4.png","crunched":0,"start":10242188,"end":10243323,"audio":false},{"filename":"/resources/sprites/Parts/cockpitYellow_5.png","crunched":0,"start":10243323,"end":10244432,"audio":false},{"filename":"/resources/sprites/Parts/cockpitYellow_6.png","crunched":0,"start":10244432,"end":10245548,"audio":false},{"filename":"/resources/sprites/Parts/cockpitYellow_7.png","crunched":0,"start":10245548,"end":10247103,"audio":false},{"filename":"/resources/sprites/Parts/engine1.png","crunched":0,"start":10247103,"end":10247489,"audio":false},{"filename":"/resources/sprites/Parts/engine2.png","crunched":0,"start":10247489,"end":10248227,"audio":false},{"filename":"/resources/sprites/Parts/engine3.png","crunched":0,"start":10248227,"end":10248789,"audio":false},{"filename":"/resources/sprites/Parts/engine4.png","crunched":0,"start":10248789,"end":10249649,"audio":false},{"filename":"/resources/sprites/Parts/engine5.png","crunched":0,"start":10249649,"end":10250007,"audio":false},{"filename":"/resources/sprites/Parts/gun00.png","crunched":0,"start":10250007,"end":10250352,"audio":false},{"filename":"/resources/sprites/Parts/gun01.png","crunched":0,"start":10250352,"end":10250728,"audio":false},{"filename":"/resources/sprites/Parts/gun02.png","crunched":0,"start":10250728,"end":10251170,"audio":false},{"filename":"/resources/sprites/Parts/gun03.png","crunched":0,"start":10251170,"end":10251740,"audio":false},{"filename":"/resources/sprites/Parts/gun04.png","crunched":0,"start":10251740,"end":10252088,"audio":false},{"filename":"/resources/sprites/Parts/gun05.png","crunched":0,"start":10252088,"end":10252649,"audio":false},{"filename":"/resources/sprites/Parts/gun06.png","crunched":0,"start":10252649,"end":10253027,"audio":false},{"filename":"/resources/sprites/Parts/gun07.png","crunched":0,"start":10253027,"end":10253473,"audio":false},{"filename":"/resources/sprites/Parts/gun08.png","crunched":0,"start":10253473,"end":10253852,"audio":false},{"filename":"/resources/sprites/Parts/gun09.png","crunched":0,"start":10253852,"end":10254368,"audio":false},{"filename":"/resources/sprites/Parts/gun10.png","crunched":0,"start":10254368,"end":10254889,"audio":false},{"filename":"/resources/sprites/Parts/scratch1.png","crunched":0,"start":10254889,"end":10255221,"audio":false},{"filename":"/resources/sprites/Parts/scratch2.png","crunched":0,"start":10255221,"end":10255638,"audio":false},{"filename":"/resources/sprites/Parts/scratch3.png","crunched":0,"start":10255638,"end":10255952,"audio":false},{"filename":"/resources/sprites/Parts/turretBase_big.png","crunched":0,"start":10255952,"end":10256777,"audio":false},{"filename":"/resources/sprites/Parts/turretBase_small.png","crunched":0,"start":10256777,"end":10257376,"audio":false},{"filename":"/resources/sprites/Parts/wingBlue_0.png","crunched":0,"start":10257376,"end":10258776,"audio":false},{"filename":"/resources/sprites/Parts/wingBlue_1.png","crunched":0,"start":10258776,"end":10260030,"audio":false},{"filename":"/resources/sprites/Parts/wingBlue_2.png","crunched":0,"start":10260030,"end":10261125,"audio":false},{"filename":"/resources/sprites/Parts/wingBlue_3.png","crunched":0,"start":10261125,"end":10262544,"audio":false},{"filename":"/resources/sprites/Parts/wingBlue_4.png","crunched":0,"start":10262544,"end":10263591,"audio":false},{"filename":"/resources/sprites/Parts/wingBlue_5.png","crunched":0,"start":10263591,"end":10264922,"audio":false},{"filename":"/resources/sprites/Parts/wingBlue_6.png","crunched":0,"start":10264922,"end":10266195,"audio":false},{"filename":"/resources/sprites/Parts/wingBlue_7.png","crunched":0,"start":10266195,"end":10267734,"audio":false},{"filename":"/resources/sprites/Parts/wingGreen_0.png","crunched":0,"start":10267734,"end":10269144,"audio":false},{"filename":"/resources/sprites/Parts/wingGreen_1.png","crunched":0,"start":10269144,"end":10270401,"audio":false},{"filename":"/resources/sprites/Parts/wingGreen_2.png","crunched":0,"start":10270401,"end":10271507,"audio":false},{"filename":"/resources/sprites/Parts/wingGreen_3.png","crunched":0,"start":10271507,"end":10272950,"audio":false},{"filename":"/resources/sprites/Parts/wingGreen_4.png","crunched":0,"start":10272950,"end":10274005,"audio":false},{"filename":"/resources/sprites/Parts/wingGreen_5.png","crunched":0,"start":10274005,"end":10275345,"audio":false},{"filename":"/resources/sprites/Parts/wingGreen_6.png","crunched":0,"start":10275345,"end":10276628,"audio":false},{"filename":"/resources/sprites/Parts/wingGreen_7.png","crunched":0,"start":10276628,"end":10278167,"audio":false},{"filename":"/resources/sprites/Parts/wingRed_0.png","crunched":0,"start":10278167,"end":10279256,"audio":false},{"filename":"/resources/sprites/Parts/wingRed_1.png","crunched":0,"start":10279256,"end":10280498,"audio":false},{"filename":"/resources/sprites/Parts/wingRed_2.png","crunched":0,"start":10280498,"end":10281902,"audio":false},{"filename":"/resources/sprites/Parts/wingRed_3.png","crunched":0,"start":10281902,"end":10282943,"audio":false},{"filename":"/resources/sprites/Parts/wingRed_4.png","crunched":0,"start":10282943,"end":10284263,"audio":false},{"filename":"/resources/sprites/Parts/wingRed_5.png","crunched":0,"start":10284263,"end":10285528,"audio":false},{"filename":"/resources/sprites/Parts/wingRed_6.png","crunched":0,"start":10285528,"end":10287054,"audio":false},{"filename":"/resources/sprites/Parts/wingRed_7.png","crunched":0,"start":10287054,"end":10288450,"audio":false},{"filename":"/resources/sprites/Parts/wingYellow_0.png","crunched":0,"start":10288450,"end":10289796,"audio":false},{"filename":"/resources/sprites/Parts/wingYellow_1.png","crunched":0,"start":10289796,"end":10291004,"audio":false},{"filename":"/resources/sprites/Parts/wingYellow_2.png","crunched":0,"start":10291004,"end":10292070,"audio":false},{"filename":"/resources/sprites/Parts/wingYellow_3.png","crunched":0,"start":10292070,"end":10293443,"audio":false},{"filename":"/resources/sprites/Parts/wingYellow_4.png","crunched":0,"start":10293443,"end":10294457,"audio":false},{"filename":"/resources/sprites/Parts/wingYellow_5.png","crunched":0,"start":10294457,"end":10295748,"audio":false},{"filename":"/resources/sprites/Parts/wingYellow_6.png","crunched":0,"start":10295748,"end":10296982,"audio":false},{"filename":"/resources/sprites/Parts/wingYellow_7.png","crunched":0,"start":10296982,"end":10298473,"audio":false},{"filename":"/resources/sprites/Power-ups/bold_silver.png","crunched":0,"start":10298473,"end":10299010,"audio":false},{"filename":"/resources/sprites/Power-ups/bolt_bronze.png","crunched":0,"start":10299010,"end":10299593,"audio":false},{"filename":"/resources/sprites/Power-ups/bolt_gold.png","crunched":0,"start":10299593,"end":10300152,"audio":false},{"filename":"/resources/sprites/Power-ups/pill_blue.png","crunched":0,"start":10300152,"end":10300666,"audio":false},{"filename":"/resources/sprites/Power-ups/pill_green.png","crunched":0,"start":10300666,"end":10301178,"audio":false},{"filename":"/resources/sprites/Power-ups/pill_red.png","crunched":0,"start":10301178,"end":10301683,"audio":false},{"filename":"/resources/sprites/Power-ups/pill_yellow.png","crunched":0,"start":10301683,"end":10302179,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupBlue.png","crunched":0,"start":10302179,"end":10302646,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupBlue_bolt.png","crunched":0,"start":10302646,"end":10303247,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupBlue_shield.png","crunched":0,"start":10303247,"end":10303831,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupBlue_star.png","crunched":0,"start":10303831,"end":10304450,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupGreen.png","crunched":0,"start":10304450,"end":10304915,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupGreen_bolt.png","crunched":0,"start":10304915,"end":10305515,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupGreen_shield.png","crunched":0,"start":10305515,"end":10306098,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupGreen_star.png","crunched":0,"start":10306098,"end":10306716,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupRed.png","crunched":0,"start":10306716,"end":10307173,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupRed_bolt.png","crunched":0,"start":10307173,"end":10307765,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupRed_shield.png","crunched":0,"start":10307765,"end":10308340,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupRed_star.png","crunched":0,"start":10308340,"end":10308950,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupYellow.png","crunched":0,"start":10308950,"end":10309402,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupYellow_bolt.png","crunched":0,"start":10309402,"end":10309967,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupYellow_shield.png","crunched":0,"start":10309967,"end":10310519,"audio":false},{"filename":"/resources/sprites/Power-ups/powerupYellow_star.png","crunched":0,"start":10310519,"end":10311097,"audio":false},{"filename":"/resources/sprites/Power-ups/shield_bronze.png","crunched":0,"start":10311097,"end":10311891,"audio":false},{"filename":"/resources/sprites/Power-ups/shield_gold.png","crunched":0,"start":10311891,"end":10312686,"audio":false},{"filename":"/resources/sprites/Power-ups/shield_silver.png","crunched":0,"start":10312686,"end":10313467,"audio":false},{"filename":"/resources/sprites/Power-ups/star_bronze.png","crunched":0,"start":10313467,"end":10314158,"audio":false},{"filename":"/resources/sprites/Power-ups/star_gold.png","crunched":0,"start":10314158,"end":10314833,"audio":false},{"filename":"/resources/sprites/Power-ups/star_silver.png","crunched":0,"start":10314833,"end":10315470,"audio":false},{"filename":"/resources/sprites/Power-ups/things_bronze.png","crunched":0,"start":10315470,"end":10316048,"audio":false},{"filename":"/resources/sprites/Power-ups/things_gold.png","crunched":0,"start":10316048,"end":10316613,"audio":false},{"filename":"/resources/sprites/Power-ups/things_silver.png","crunched":0,"start":10316613,"end":10317149,"audio":false},{"filename":"/resources/sprites/UI/buttonBlue.png","crunched":0,"start":10317149,"end":10317618,"audio":false},{"filename":"/resources/sprites/UI/buttonGreen.png","crunched":0,"start":10317618,"end":10318104,"audio":false},{"filename":"/resources/sprites/UI/buttonRed.png","crunched":0,"start":10318104,"end":10318580,"audio":false},{"filename":"/resources/sprites/UI/buttonYellow.png","crunched":0,"start":10318580,"end":10319044,"audio":false},{"filename":"/resources/sprites/UI/cursor.png","crunched":0,"start":10319044,"end":10319979,"audio":false},{"filename":"/resources/sprites/UI/numeral0.png","crunched":0,"start":10319979,"end":10320212,"audio":false},{"filename":"/resources/sprites/UI/numeral1.png","crunched":0,"start":10320212,"end":10320465,"audio":false},{"filename":"/resources/sprites/UI/numeral2.png","crunched":0,"start":10320465,"end":10320694,"audio":false},{"filename":"/resources/sprites/UI/numeral3.png","crunched":0,"start":10320694,"end":10320920,"audio":false},{"filename":"/resources/sprites/UI/numeral4.png","crunched":0,"start":10320920,"end":10321169,"audio":false},{"filename":"/resources/sprites/UI/numeral5.png","crunched":0,"start":10321169,"end":10321395,"audio":false},{"filename":"/resources/sprites/UI/numeral6.png","crunched":0,"start":10321395,"end":10321631,"audio":false},{"filename":"/resources/sprites/UI/numeral7.png","crunched":0,"start":10321631,"end":10321855,"audio":false},{"filename":"/resources/sprites/UI/numeral8.png","crunched":0,"start":10321855,"end":10322082,"audio":false},{"filename":"/resources/sprites/UI/numeral9.png","crunched":0,"start":10322082,"end":10322320,"audio":false},{"filename":"/resources/sprites/UI/numeralX.png","crunched":0,"start":10322320,"end":10322737,"audio":false},{"filename":"/resources/sprites/UI/playerLife1_blue.png","crunched":0,"start":10322737,"end":10323508,"audio":false},{"filename":"/resources/sprites/UI/playerLife1_green.png","crunched":0,"start":10323508,"end":10324286,"audio":false},{"filename":"/resources/sprites/UI/playerLife1_orange.png","crunched":0,"start":10324286,"end":10325057,"audio":false},{"filename":"/resources/sprites/UI/playerLife1_red.png","crunched":0,"start":10325057,"end":10325832,"audio":false},{"filename":"/resources/sprites/UI/playerLife2_blue.png","crunched":0,"start":10325832,"end":10326741,"audio":false},{"filename":"/resources/sprites/UI/playerLife2_green.png","crunched":0,"start":10326741,"end":10327659,"audio":false},{"filename":"/resources/sprites/UI/playerLife2_orange.png","crunched":0,"start":10327659,"end":10328573,"audio":false},{"filename":"/resources/sprites/UI/playerLife2_red.png","crunched":0,"start":10328573,"end":10329486,"audio":false},{"filename":"/resources/sprites/UI/playerLife3_blue.png","crunched":0,"start":10329486,"end":10330221,"audio":false},{"filename":"/resources/sprites/UI/playerLife3_green.png","crunched":0,"start":10330221,"end":10330960,"audio":false},{"filename":"/resources/sprites/UI/playerLife3_orange.png","crunched":0,"start":10330960,"end":10331698,"audio":false},{"filename":"/resources/sprites/UI/playerLife3_red.png","crunched":0,"start":10331698,"end":10332434,"audio":false},{"filename":"/resources/sprites/playerShip1_blue.png","crunched":0,"start":10332434,"end":10335132,"audio":false},{"filename":"/resources/sprites/playerShip1_green.png","crunched":0,"start":10335132,"end":10337840,"audio":false},{"filename":"/resources/sprites/playerShip1_orange.png","crunched":0,"start":10337840,"end":10340418,"audio":false},{"filename":"/resources/sprites/playerShip1_red.png","crunched":0,"start":10340418,"end":10343128,"audio":false},{"filename":"/resources/sprites/playerShip2_blue.png","crunched":0,"start":10343128,"end":10346919,"audio":false},{"filename":"/resources/sprites/playerShip2_green.png","crunched":0,"start":10346919,"end":10350719,"audio":false},{"filename":"/resources/sprites/playerShip2_orange.png","crunched":0,"start":10350719,"end":10354316,"audio":false},{"filename":"/resources/sprites/playerShip2_red.png","crunched":0,"start":10354316,"end":10358113,"audio":false},{"filename":"/resources/sprites/playerShip3_blue.png","crunched":0,"start":10358113,"end":10360947,"audio":false},{"filename":"/resources/sprites/playerShip3_green.png","crunched":0,"start":10360947,"end":10363794,"audio":false},{"filename":"/resources/sprites/playerShip3_orange.png","crunched":0,"start":10363794,"end":10366519,"audio":false},{"filename":"/resources/sprites/playerShip3_red.png","crunched":0,"start":10366519,"end":10369371,"audio":false},{"filename":"/resources/sprites/sprites.lua","crunched":0,"start":10369371,"end":10395660,"audio":false},{"filename":"/resources/sprites/ufoBlue.png","crunched":0,"start":10395660,"end":10398703,"audio":false},{"filename":"/resources/sprites/ufoGreen.png","crunched":0,"start":10398703,"end":10401752,"audio":false},{"filename":"/resources/sprites/ufoRed.png","crunched":0,"start":10401752,"end":10404802,"audio":false},{"filename":"/resources/sprites/ufoYellow.png","crunched":0,"start":10404802,"end":10407843,"audio":false},{"filename":"/world/backdrop.lua","crunched":0,"start":10407843,"end":10409624,"audio":false},{"filename":"/world/wave.lua","crunched":0,"start":10409624,"end":10416595,"audio":false},{"filename":"/world/world.lua","crunched":0,"start":10416595,"end":10425229,"audio":false}]});

})();
