# git stash enhancement module
module BigStash
  # git stash enhancement operator
  class StashOperator
    attr_reader :stashes

    def initialize(path)
      @stashes = {}
      @path = path
      IO.popen("cd #{@path}; git stash list") do |io|
        io.each do |line|
          items = line.chop.split(/: /)
          @stashes[items.last] = items.first
        end
      end
    end

    def stash(name)
      if @stashes[name]
        raise "Already have a stash with name #{name}"
      else
        if can_stash
          p `cd #{@path}; git stash save #{name}`
        else
          p 'Nothing to stash, working tree clean, continue...'
        end
      end
    end

    def can_stash
      can_stash = true
      clear_flag = 'nothing to commit, working tree clean'
      IO.popen("cd #{@path}; git status") do |io|
        io.each do |line|
          can_stash = false if line.include? clear_flag
        end
      end
      can_stash
    end

    def apply_stash(name)
      if @stashes[name]
        p `cd #{@path}; git stash apply #{@stashes[name]}`
      else
        p %(Nothing to apply, can not find the stash with name '#{name}', continue...)
      end
    end

    def pop_stash(name)
      if @stashes[name]
        p `cd #{@path}; git stash pop #{@stashes[name]}`
      else
        p %(Nothing to pop, can not find the stash with name '#{name}', continue...)
      end
    end

    def stash_for_name(name)
      @stashes[name]
    end

    private :can_stash
  end
end
