function results = run_tests(outputFolder)
%RUN_TESTS Execute real MATLAB unit tests; fail the batch on any failed test.
root = fileparts(mfilename('fullpath')); addpath(root);
if nargin < 1, outputFolder = fullfile(root,'results','verification'); end
if ~isfolder(outputFolder), mkdir(outputFolder); end
suite = testsuite(fullfile(root,'tests'),'IncludeSubfolders',true);
runner = matlab.unittest.TestRunner.withTextOutput;
runner.addPlugin(matlab.unittest.plugins.XMLPlugin.producingJUnitFormat( ...
    fullfile(outputFolder,'junit.xml')));
results = runner.run(suite);
name = string({results.Name})'; passed = [results.Passed]';
failed = [results.Failed]'; incomplete = [results.Incomplete]';
duration_s = [results.Duration]';
writetable(table(name,passed,failed,incomplete,duration_s), ...
    fullfile(outputFolder,'tests.csv'));
assertSuccess(results);
end
