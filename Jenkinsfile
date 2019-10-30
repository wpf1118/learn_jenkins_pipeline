
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
                ssh -p 22 root@${ip} "rm -rf /dockerfiles"

                echo "PHP_FPM_IMAGE=${env.DOCKER_REPO}/${docker_namespace}/crs-php-${project}-${run_env}-${image_hash}:${tag}" > dockerfiles/.env

                echo "ENTERPRISE_HASH=${image_hash}" >> dockerfiles/.env
                echo "PROJECT=${project}" >> dockerfiles/.env
                echo "RUN_ENV=${run_env}" >> dockerfiles/.env

                scp -r dockerfiles root@${ip}:/

                ssh -p 22 root@${ip} "cd /dockerfiles && sed -i '3s/php-fpm/php-fpm-${project}-${run_env}-${image_hash}/g' docker-compose.yml"

                ssh -p 22 root@${ip} "chmod +x /dockerfiles/kill-container.sh && /dockerfiles/kill-container.sh ${env.DOCKER_REPO}/${docker_namespace}/crs-php-${project}-${run_env}-${image_hash}"

                ssh -p 22 root@${ip} "mkdir -p /data/www/console-api-test-crs.vchangyi.com/${image_hash}"

                ssh -p 22 root@${ip} "chown -R 1000:1000 /data/www/console-api-test-crs.vchangyi.com/${image_hash}"

                ssh -p 22 root@${ip} "cd /dockerfiles && docker-compose up -d"

            """
        }
    }

    return parallelDeploy
}

node{

    String enterprise_hash = ''
    String enterprise_name = ''
    String docker_namespace = 'czht1118'
    String project = 'console'

    def hostsConf = [
            "juxiangpro:ecd85280aa135bbd0108dd6aa424565a": [
                "127.0.0.1",
            ],
            "default" : [
                "127.0.0.1",
            ],
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
            choice(choices: enterpriseList, description: '发布企业', name: 'enterprise'),
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

    stage('build image') {

        def image_hash = enterprise_hash
        if(image_hash=="") {
            image_hash="public"
        }

        sh """
            docker build . -f dockerfiles/Dockerfile -t ${env.DOCKER_REPO}/${docker_namespace}/crs-php-${project}-${run_env}-${image_hash}:${tag} --no-cache
        """
    }

    stage('push image') {

        def image_hash = enterprise_hash
        if(image_hash=="") {
            image_hash="public"
        }

        sh """
            docker login --username ${env.DOCKER_USER} --password ${env.DOCKER_PWD}
            docker push czht1118/crs_shop:${tag}
        """
    }

    // stage('deploy Blue') {
    //     def hosts = hostsConf[enterprise]
    //     def deploy_hosts = hosts_split(hosts)[0]
    //     if (deploy_hosts.size() == 0) {
    //         println("Skip Stage：Deploy Blue.")
    //         return
    //     }

    //     def blue = deply_stage_host(
    //         'Blue',
    //         deploy_hosts,
    //         enterprise_hash,
    //         enterprise_name,
    //         docker_namespace,
    //         tag,
    //         run_env,
    //         project
    //     );

    //     parallel blue;
    // }

    // stage('deploy Green') {
    //     def hosts = hostsConf[enterprise]
    //     def deploy_hosts = hosts_split(hosts)[1]
    //     if (deploy_hosts.size() == 0) {

    //         println("Skip Stage：Deploy Green.")
    //         return
    //     }

    //     def green = deply_stage_host(
    //             'Green',
    //             deploy_hosts,
    //             enterprise_hash,
    //             enterprise_name,
    //             docker_namespace,
    //             tag,
    //             run_env,
    //             project
    //         );

    //     parallel green;
    // }
}
