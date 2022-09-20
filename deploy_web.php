<?php

namespace Deployer;

require 'recipe/common.php';
set('project_name', getenv('PROJECT_NAME'));
$deployPath = '/data/www/{{project_name}}';
set('deploy_path', $deployPath);
set('allow_anonymous_stats', false);
set('default_stage', 'test');
set('deployer', 'deployer2');
set('keep_releases', 10);
$user = 'deployer2';

host('test.youshangjiao.com.cn')
    ->user($user)
    ->set('http_user', $user)
    ->port(3222)
    ->set('stage', 'test')
    ->set('branch', 'test');

host('47.103.89.57')
    ->user($user)
    ->set('http_user', $user)
    ->port(3222)
    ->set('stage', 'prod')
    ->set('branch', 'prod');

desc('Upload code');
task('deploy:upload_code', function () {
    $sourcePath = 'dist/';
    if (get('project_name') === 'www') {
        $sourcePath = './';
    }
    $count = 0;
    maodian:
    try {
        runLocally('pwd & ls -al');
        $count++;
        upload($sourcePath, "{{release_path}}/");
    } catch (\Throwable $t) {
        if ($count < 10) {
            sleep(3);
            goto maodian;
        } else {
            throw $t;
        }
    }
});

desc('检查发布tag是否存在于prod分支中');
task('deploy:check', function () {
    if (getenv('GITHUB_REF_TYPE') === 'tag') {
        runLocally('git -c protocol.version=2 fetch --no-tags --prune --progress --no-recurse-submodules --depth=5 origin prod');
        if (!testLocally("git merge-base --is-ancestor " . getenv('GITHUB_REF_NAME') . " origin/prod")) {
            throw new \Exception(getenv('GITHUB_REF_NAME') . ' 应位于prod分支');
        }
    }
});

if (getenv('STAGE') === 'prod') {
    //生产环境不自动生效
    task('deploy:symlink', function () {
        //do nothing
    });
}

desc('Deploy project');
task('deploy', [
    'deploy:info',
    'deploy:prepare',
    'deploy:check',
    'deploy:lock',
    'deploy:release',
    'deploy:upload_code',
    'deploy:symlink',
    'deploy:unlock',
    'cleanup',
]);
after('deploy', 'success');
after('deploy:failed', 'deploy:unlock');
