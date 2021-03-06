#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2013 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

namespace :copyright do
  namespace :authors do
    desc "Shows contributors to a project"
    task :show, :arg1 do |task, args|
      contribution_periods = contribution_periods_of_project(args[:arg1])

      show_contribution_periods(contribution_periods)
    end

    private

    CONTRIBUTION = Struct.new(:author, :date)
    CONTRIBUTION_PERIOD = Struct.new(:author, :begin, :end)

    CONTRIBUTION_REGEX = /^(?<date>\d\d\d\d-\d\d-\d\d) (?<author>.*)$/

    def contribution_periods_of_project(path)
      contributions = []
      contribution_periods = []
      path = '.' if path.nil?
      log = `git --git-dir #{path}/.git log --date=short --pretty=format:"%ad %aN"`

      log.scan(CONTRIBUTION_REGEX).each do |m|
        contributions << CONTRIBUTION.new(m[1], Date.parse(m[0]))
      end

      authors = contributions.collect(&:author).uniq

      authors.each do |a|
        first, last = contributions.select{ |c| c.author == a }
                                   .minmax{ |a, b| a.date <=> b.date }
        contribution_periods << CONTRIBUTION_PERIOD.new(a, first.date.year, last.date.year)
      end

      contribution_periods.sort_by{ |c| [c.end, c.begin] }.reverse
    end

    def show_contribution_periods(contribution_periods)
      contribution_periods.each do |c| 
        period = (c.begin == c.end) ? c.begin.to_s : "#{c.begin} - #{c.end}"
        puts "#{period} #{c.author}"
      end
    end
  end
end
