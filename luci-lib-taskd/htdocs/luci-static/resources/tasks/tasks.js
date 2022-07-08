
(function(){
    const taskd={};
    const $gettext = function(str) {
        return taskd.i18n[str] || str;
    };
    const request = function(url, method, data) {
        return new Promise((resolve, reject) => {
            var oReq = new XMLHttpRequest();
            oReq.open(method || 'GET', url, true);

            oReq.onload = function (oEvent) {
                resolve(oReq.responseText);
            };
            if (method=='POST') {
                oReq.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            }
            oReq.send(data || method=='POST'?"token="+taskd.csrfToken:null);
        });
    };
    const getBin = function(url) {
        return new Promise((resolve, reject) => {
            var oReq = new XMLHttpRequest();
            oReq.open("GET", url, true);
            oReq.responseType = "arraybuffer";
    
            oReq.onload = function (oEvent) {
                resolve({status: oReq.status, buffer: new Uint8Array(oReq.response)});
            };
            
            oReq.send(null);
        });
    };
    const getTaskDetail = function(task_id) {
        return request("/cgi-bin/luci/admin/system/tasks/status?task_id="+task_id).then(data=>JSON.parse(data));
    };
    const show_log = function(task_id, nohide) {
        let showing = true;
        let running = true;
        const container = document.createElement('div');
        container.id = "tasks_detail_container";
        container.innerHTML = taskd.dialog_template;

        document.body.appendChild(container);
        const title_view = container.querySelector(".dialog-title-bar .dialog-title");
        title_view.innerText = task_id;
        container.querySelector(".dialog-icon-close").onclick = function(){
            if (!running || confirm($gettext("Stop running task?"))) {
                running=false;
                showing=false;
                del_task(task_id).then(()=>{
                    location.href = location.href;
                });
            }
            return false;
        };
        const term = new Terminal({convertEol: true});
        if (nohide) {
            container.querySelector(".dialog-icon-min").hidden = true;
        } else {
            container.querySelector(".dialog-icon-min").onclick = function(){
                container.hidden=true;
                showing=false;
                term.dispose();
                document.body.removeChild(container);
                return false;
            };
        }
        //window.xterm=term;
        term.open(document.getElementById("tasks_xterm_log"));
        const checkTask = function() {
            return getTaskDetail(task_id).then(data=>{
                if (!running) {
                    return false;
                }
                running = data.running;
                let title = task_id;
                if (!data.running && data.stop) {
                    title += " (" + (data.exit_code==0?$gettext("Finished at:"):$gettext("Failed at:")) + " " + new Date(data.stop * 1000).toLocaleString() + ")";
                }
                title += " > " + (data.command || '');
                title_view.title = title;
                title_view.innerText = title;
                return data.running;
            });
        };
        let logoffset = 0;
        const pulllog = function() {
            getBin("/cgi-bin/luci/admin/system/tasks/log?task_id="+task_id+"&offset="+logoffset).then(function(res){
                if (!showing) {
                    return false;
                }
                switch(res.status){
                    case 205:
                        term.reset();
                        logoffset = 0;
                        return running;
                        break;
                    case 204:
                        return running && checkTask();
                        break;
                    case 200:
                        logoffset += res.buffer.byteLength;
                        term.write(res.buffer);
                        return running;
                        break;
                }
            }).then(again => {
                if (again) {
                    setTimeout(pulllog, 0);
                }
            });
        };
        checkTask().then(pulllog);
    };
    const del_task = function(task_id) {
        return request("/cgi-bin/luci/admin/system/tasks/stop?task_id="+task_id, "POST");
    };
    taskd.show_log = show_log;
    taskd.remove = del_task;
    window.taskd=taskd;
})();
