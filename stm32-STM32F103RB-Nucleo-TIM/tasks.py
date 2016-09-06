from invoke import run, config, task
import os
import shutil

root = lambda p: os.path.abspath(os.path.dirname(__file__) + '/' + p)
do = lambda ctx, path, c: ctx.run('cd {} && {}'.format(root(path), c))

ROOT = root('')
BUILD_PATH = 'build'


@task
def env(ctx):
	os.environ["PATH"] = os.pathsep.join(ctx.path.values()) + os.pathsep + os.environ["PATH"]


@task(env)
def all(ctx):
	print("all...")
	do(ctx, BUILD_PATH, '"{}" -j8 all'.format(ctx.make.gnu_mingw32_make))


@task(all)
def make(ctx):
	print("make...")
	pass


@task(env)
def clean(ctx):
	print("clean...")
	do(ctx, BUILD_PATH, '"{}" clean'.format(ctx.make.gnu_mingw32_make))


@task
def clean_all(ctx):
    if os.path.isdir(BUILD_PATH):
    	shutil.rmtree(BUILD_PATH, ignore_errors=True)


@task
def flash(ctx):
	print("not implemented...")


@task
def diff(ctx):
	ctx.run("git difftool --dir-diff")



@task(env)
def configure(ctx):
	if not os.path.exists(BUILD_PATH):
		os.mkdir(BUILD_PATH)
	do(ctx, BUILD_PATH, 'cmake.exe -G "MinGW Makefiles" -C ../build_settings.cmake -DCMAKE_BUILD_TYPE=Debug ../')


@task(all)
def build(ctx):
	pass


@task(pre=[clean, all])
def rebuild(ctx):
	pass


@task(pre=[clean_all, configure, all])
def rebuild_all(ctx):
	pass


@task(pre=[clean, all, flash])
def bfa(ctx):
	print("build and flash completed...")

