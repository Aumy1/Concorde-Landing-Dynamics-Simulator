function fig = aircraft_selector()
%AIRCRAFT_SELECTOR Choose a civilian landing replay.
choice = menu('Aircraft landing simulator','Concorde - British Airways','A350 - Air Canada (Sunset)','A350 - Air Canada (Day)');
fig = [];
if choice == 1, fig = landing_replay(); end
if choice == 2, fig = run_a350(); end
if choice == 3, fig = run_a350('day'); end
end
