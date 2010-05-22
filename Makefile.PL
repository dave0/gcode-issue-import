use inc::Module::Install;

name      'App-GooglecodeIssueImport';
all_from  'gcode-issue-import';

requires  'Net::Google::Code' => '0.19';
requires  'Net::GitHub'       => '0.21';

install_script 'gcode-issue-import';

postamble <<END_MAKE;
readme:
	perldoc -u gcode-issue-import > README.pod
END_MAKE

WriteAll;
