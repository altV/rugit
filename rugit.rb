#!/usr/bin/ruby
require "bundler"; Bundler.require
require 'open-uri'

class Rugit
  singleton_class.send :attr_accessor, :num_people, :num_features, :max_commits_in_feature

  self.num_people   ||= 5
  self.num_features ||= 10
  self.max_commits_in_feature ||= 6

  class <<self
    def create_repo
      dir = Randgen.word
      system "mkdir #{dir}"; Dir.chdir dir
      system "git init ."
      File.open("masterfile.txt","w") {|f| f.write(Randgen.paragraph)}
      system 'git add .'
      system "git commit -m 'master'"
      commits_on_timeline.each do |c|
        name = c.delete("_")[/\w+/]
        first_commit = c["1"]
        last_commit  = c["_"]

        if first_commit
          system "git checkout -b feat/#{name}"
        else
          system "git checkout feat/#{name}"
        end
        File.open("#{name}.txt","w") {|f| f.write(Randgen.paragraph)} #todo: change write mode and to .sentence
        system 'git add .'
        system "git commit -m '#{commit_message.delete("'")}'"
        system "git checkout master"
        if last_commit
          system "git merge --no-commit --no-ff feat/#{name}"
          system "git add ."
          system "git commit -m 'merge'"
        end
      end

    end

    def people
      @people ||= (1..num_people).map { {name:  "#{Randgen.first_name}", # #{Randgen.last_name}",
      email: "#{Randgen.email}"} }
    end

    def features
      @features ||= (1..num_features).map { Randgen.word }
    end

    def commits
      features.map {|f| (1..(rand*max_commits_in_feature+1)).map {|i| "#{f}-#{i}"} }
    end


    def commits_on_timeline
      [].tap {|a|
        commits.map {|f| f[-1] = "_" + f[-1]; f }
        .tap{|c| c.flatten.size.times.each { a<< c1=c[c.size*rand].delete_at(0); c.delete([])  } }
      }
    end

    def commit_message
      open("http://whatthecommit.com").read[/(?<=content">\n<p>).+(?=\n)/]
    end
  end

  def system param
    puts "                 #{param}"
    Kernel.system param
  end
end

Rugit.create_repo