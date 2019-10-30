
def hosts_split(hosts) {
    if (hosts.size()>1) {
        def mid = (hosts.size()/2).intValue()
        def a = []
        def b = []
        for (int i = 0; i < mid; i++) {
            a.add(hosts.get(i))
        }
        for (int i = mid; i < hosts.size(); i++) {
            b.add(hosts.get(i))
        }
        return [a, b]
    }
    return [hosts,[]];
}

def deply_stage_host(stage, hosts, enterprise_hash, enterprise_name, docker_namespace, tag, run_env, project) {
    def image_hash = enterprise_hash
    if(image_hash=="") {
        image_hash="public"
    }

    def parallelDeploy  = [:]

    for (int i = 0; i < hosts.size(); i++) {
        def ip = hosts[i];
        parallelDeploy["deploy-${stage}-task-${ip}"] = {
            sh """
                echo "PHP_FPM_IMAGE=${env.DOCKER_REPO}/${docker_namespace}/crs-php-${project}-${run_env}-${image_hash}:${tag}" > dockerfiles/.env
                
                echo "ENTERPRISE_HASH=${image_hash}" >> dockerfiles/.env
                echo "PROJECT=${project}" >> dockerfiles/.env

                scp -r dockerfiles root@${ip}:/

                ssh -p 22 root@${ip} "cd /dockerfiles && sed -i '3s/php-fpm/php-fpm-${project}-${image_hash}/g' docker-compose.yml"

                ssh -p 22 root@${ip} "chmod +x /dockerfiles/kill-container.sh && /dockerfiles/kill-container.sh ${env.DOCKER_REPO}/${docker_namespace}/crs-php-${project}-${run_env}-${image_hash}"

                ssh -p 22 root@${ip} "mkdir -p /data/www/console-api-crs.vchangyi.com/${image_hash}"

                ssh -p 22 root@${ip} "chown -R 1000:1000 /data/www/console-api-crs.vchangyi.com/${image_hash}"

                ssh -p 22 root@${ip} "cd /dockerfiles && docker-compose up -d"

                ssh -p 22 root@${ip} "rm -rf /dockerfiles"
            """
        }
    }

    return parallelDeploy
}

node{

    String enterprise_hash = ''
    String enterprise_name = ''
    String docker_namespace = 'crs-backend'
    String project = 'console'

    def hostsConf = [
            "default" : [
                "127.0.0.1",
            ],
            "juxiangxinxi:79066ecdb52334c1f6eb7795fcffd44e" : [
                "127.0.0.1",
            ]
        ];

    def enterpriseList = []
    enterpriseList.addAll(hostsConf.keySet())

    properties([
        buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '5')),
        parameters([
            gitParameter(
                branch: '',
                branchFilter: '.*',
                defaultValue: 'master',
                description: '发布的分支或tag',
                name: 'version',
                quickFilterEnabled: false,
                selectedValue: 'NONE',
                sortMode: 'NONE',
                tagFilter: '*',
                type: 'PT_BRANCH_TAG'),
            choice(choices: enterpriseList, description: '''发布企业
                                                                     default发布分支：master
                                                                     ''', name: 'enterprise'),
            string(defaultValue: 'test', description: '运行环境', name: 'run_env', trim: true)
        ])
    ])

    stage('scm') {
        checkout([
            $class: 'GitSCM',
            branches: [[name: "${version}"]],
            doGenerateSubmoduleConfigurations: false,
            extensions: [],
            submoduleCfg: [],
            userRemoteConfigs: [[
                credentialsId: 'git_hub',
                url: 'git@github.com:wpf1118/learn_jenkins_pipeline.git'
            ]]
        ])
    }

    def tag = version.replaceAll('/','.') + '.' + env.BUILD_NUMBER

    def enterprise_arr = enterprise.split(':')
    if (enterprise_arr.size() > 1) {
        enterprise_name = enterprise_arr[0];
        enterprise_hash = enterprise_arr[1]
    }

    
}
