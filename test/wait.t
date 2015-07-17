#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
###############################################################################
#
# Copyright 2006 - 2015, Paul Beckingham, Federico Hernandez.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# http://www.opensource.org/licenses/mit-license.php
#
###############################################################################

import sys
import os
import unittest
# Ensure python finds the local simpletap module
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from basetest import Task, TestCase


class TestWait(TestCase):
    def setUp(self):
        self.t = Task()
        self.t.config("report.ls.columns", "id,project,priority,description")
        self.t.config("report.ls.labels", "ID,Proj,Pri,Description")
        self.t.config("report.ls.sort", "priority-,project+")
        self.t.config("report.ls.filter", "status:pending")

    def test_visibility_waiting(self):
        """visibility of waiting tasks"""
        # Create 2 tasks with waiting times:
        #  [1] an hour before current time (visible 'now')
        #  [2] 22 hours after current time (hidden 'now', visible 'tomorrow')
        self.t.faketime("-2h")
        self.t("add wait:1h visible")
        self.t("add wait:1d hidden")

        self.t.faketime()
        code, out, err = self.t("ls")
        self.assertIn("visible", out)
        self.assertNotIn("hidden", out)

        self.t.faketime("+1d")
        code, out, err = self.t("ls")
        self.assertIn("visible", out)
        self.assertIn("hidden", out)


class TestBug434(TestCase):
    # Bug #434: Task should not prevent users from marking as done tasks with
    #           status:waiting
    def setUp(self):
        self.t = Task()

    def test_complete_waiting(self):
        """completion of waiting tasks"""
        self.t("add One wait:tomorrow")

        code, out, err = self.t("1 done")
        self.assertIn("Completed 1 task", out)

        code, out, err = self.t.runError("ls")
        self.assertNotIn("One", out)
        self.assertIn("No matches", err)


if __name__ == "__main__":
    from simpletap import TAPTestRunner
    unittest.main(testRunner=TAPTestRunner())

# vim: ai sts=4 et sw=4
