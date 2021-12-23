<?php

namespace Deployer;

require 'recipe/common.php';
set('project_name', getenv('PROJECT_NAME'));
$deployPath = '/data/www/{{project_name}}';
set('deploy_path', $deployPath);
set('allow_anonymous_stats', false);
set('default_stage', 'test');
set('deployer', 'deployer2');
$user = 'deployer2';

host('test.youshangjiao.com.cn')
    ->user($user)
    ->set('http_user', $user)
    ->port(3222)
    ->set('stage', 'test')
    ->set('branch', 'test');

host('youshangjiao.com.cn')
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
        $count++;
        upload($sourcePath, "{{release_path}}/");
    } catch (\Throwable $t) {
        if ($count < 5) {
            sleep(3);
            goto maodian;
        } else {
            throw $t;
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
    'deploy:lock',
    'deploy:release',
    'deploy:upload_code',
    'deploy:symlink',
    'deploy:unlock',
    'cleanup',
]);
after('deploy', 'success');
after('deploy:failed', 'deploy:unlock');
