worker_processes 1

listen "/home/yysaki/redmine/tmp/unicorn_redmine.sock", :backlog => 32
pid "tmp/pids/unicorn.pid"

stderr_path 'log/unicorni_error.log'
stdout_path 'log/unicorn.log'

preload_app true
check_client_connection false

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  begin
    uid, gid = Process.euid, Process.egid
    user, group = "yysaki", "yysaki"
    ENV["HOME"] = "/home/yysaki/redmine"
    target_uid = Etc.getpwnam(user).uid
    target_gid = Etc.getgrnam(group).gid
    worker.tmp.chown(target_uid, target_gid)
    if uid != target_uid or gid != target.gid
      Process.initgroups(user, target_gid)
      Process::GID.change_privilege(target_gid)
      Process::UID.change_privilege(target_uid)
    end
  rescue
    if RAILS_ENV = "development"
      STDERR.puts "could not change user, oh well"
    else
      STDERR.puts "could not change user, oh well"
      raise e
    end
  end
end

