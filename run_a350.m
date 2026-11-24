function fig = run_a350(theme)
%RUN_A350 Simulate and replay the Air Canada-themed A350.
if nargin < 1, theme = 'sunset'; end
fig = landing_replay(landing.simulate(landing.a350Config()),theme);
end
