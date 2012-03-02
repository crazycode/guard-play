目标
===

Play单元测试是默认是通过浏览器执行的，在开发时需要不停的在IDE和浏览器之间切换，并点击按钮启动测试，十分不方便。

而Play auto-test提供了无界面运行测试的方法，但启动时间比较长。

Guard是ruby界一个文件变更触发框架，可以在指定的文件发生修改后，执行相关的命令。

为此，我实现了一个Play集成的Guard扩展： https://github.com/crazycode/guard-play

安装准备
======

Guard需要Ruby运行环境，并通过Bundler进行包管理，为此，需要确保安装有bundler包：

```bash
    sudo gem install bundler
```

配置说明
======

在Play应用目录，建立Gemfile，用于管理需要的gems包，内容如下：

```ruby
    source 'http://rubygems.org'
    gem 'guard'
    gem 'guard-play'
    group :linux do
      gem 'rb-inotify', require: nil
      gem 'libnotify', require: nil
    end
    group :darwin do
      gem 'rb-fsevent', require: nil
      gem 'growl_notify', require: nil
    end
```

同时，在reeb/trunk目录有Guardfile，定义了Guard规则，内容见最后附录，也不需要修改。


第一次运行需要执行以下命令
---------------------

对于Linux系统：

```bash
    sudo bundle install --without darwin
```

对于Mac用户：

```bash
    sudo bundle install --without linux
```

运行
===

运行以下命令，打开Guard监视：

```bash
    bundle exec guard
```
guard会进入到每一个Play应用，执行play auto-test，然后静默在后台；在发生文件修改时，guard会运行对应项目的auto-test。

如果测试失败，桌面会出来提示信息
如果出现编译问题，会提示编译错
在修正上一次测试失败或编译问题时，会提示测试成功
其它情况下，测试都通过，不会有提示信息干扰你
请不要关闭Guard 让它一直在后台运行。



附录
---

单Play!项目Guardfile样例：

```ruby
    # More info at https://github.com/guard/guard#readme
    interactor :readline

    case RbConfig::CONFIG['host_os'].downcase
    when /linux/
      # notification :libnotify
      notification :notifysend
    when /darwin/
      notification :growl_notify
    end

    guard 'play' do
      watch(%r{^app/})
      watch(%r{^conf/})
      watch(%r{^test/})
    end
````

多Play!项目Guardfile样例，把Guardfile放到所有子项目的上级目录中，通过app_path指定具体项目的路径：

```ruby
    # More info at https://github.com/guard/guard#readme
    interactor :readline

    case RbConfig::CONFIG['host_os'].downcase
    when /linux/
      # notification :libnotify
      notification :notifysend
    when /darwin/
      notification :growl_notify
    end

    guard 'play', app_path: "website/www" do
      watch(%r{^website/www/app/})
      watch(%r{^website/www/conf/})
      watch(%r{^website/www/test/})
      watch(%r{^module/})
    end

    guard 'play', app_path: "website/home" do
      watch(%r{^website/home/app/})
      watch(%r{^website/home/conf/})
      watch(%r{^website/home/test/})
      watch(%r{^module/})
    end
````
