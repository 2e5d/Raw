--[[
   ____                 ___      _        
  /___ \___ _ __ ___   / __\ ___| |_ __ _ 
 //  / / _ \ '__/ _ \ /__\/// _ \ __/ _` |
/ \_/ /  __/ | | (_) / \/  \  __/ || (_| |
\___,_\\___|_|  \___/\_____/\___|\__\__,_|
                                      
--]]

local v0 = string.char;
local v1 = string.byte;
local v2 = string.sub;
local v3 = bit32 or bit;
local v4 = v3.bxor;
local v5 = table.concat;
local v6 = table.insert;
local function v7(v24, v25)
	local v26 = {};
	for v41 = 1, #v24 do
		v6(v26, v0(v4(v1(v2(v24, v41, v41 + 1)), v1(v2(v25, 1 + (v41 % #v25), 1 + (v41 % #v25) + 1))) % 256));
	end
	return v5(v26);
end
local v8 = tonumber;
local v9 = string.byte;
local v10 = string.char;
local v11 = string.sub;
local v12 = string.gsub;
local v13 = string.rep;
local v14 = table.concat;
local v15 = table.insert;
local v16 = math.ldexp;
local v17 = getfenv or function()
	return _ENV;
end;
local v18 = setmetatable;
local v19 = pcall;
local v20 = select;
local v21 = unpack or table.unpack;
local v22 = tonumber;
local function v23(v27, v28, ...)
	local v29 = 1;
	local v30;
	v27 = v12(v11(v27, 5), v7("\227\248", "\148\205\214\180"), function(v42)
		if ((4628 == 4628) and (v9(v42, 2) == 81)) then
			local v102 = 0;
			while true do
				if (v102 == 0) then
					v30 = v8(v11(v42, 1139 - (116 + 1022), 1));
					return "";
				end
			end
		else
			local v103 = v10(v8(v42, 49 - 33));
			if (v30 or (4593 <= 2672)) then
				local v114 = 0;
				local v115;
				while true do
					if (v114 == 1) then
						return v115;
					end
					if ((v114 == 0) or (54 == 395)) then
						v115 = v13(v103, v30);
						v30 = nil;
						v114 = 1;
					end
				end
			else
				return v103;
			end
		end
	end);
	local function v31(v43, v44, v45)
		if ((82 == 82) and v45) then
			local v104 = (v43 / (2 ^ (v44 - 1))) % (2 ^ (((v45 - 1) - (v44 - (4 - 3))) + 1));
			return v104 - (v104 % 1);
		else
			local v105 = 0;
			local v106;
			while true do
				if ((v105 == 0) or (581 < 282)) then
					v106 = 2 ^ (v44 - 1);
					return (((v43 % (v106 + v106)) >= v106) and 1) or (0 - 0);
				end
			end
		end
	end
	local function v32()
		local v46 = v9(v27, v29, v29);
		v29 = v29 + 1;
		return v46;
	end
	local function v33()
		local v47 = 0;
		local v48;
		local v49;
		while true do
			if ((v47 == 0) or (1168 > 3156) or (4609 < 2495)) then
				v48, v49 = v9(v27, v29, v29 + 2);
				v29 = v29 + 2;
				v47 = 1;
			end
			if ((v47 == 1) or (572 > 4486)) then
				return (v49 * 256) + v48;
			end
		end
	end
	local function v34()
		local v50 = 0;
		local v51;
		local v52;
		local v53;
		local v54;
		while true do
			if (v50 == 0) then
				v51, v52, v53, v54 = v9(v27, v29, v29 + 3);
				v29 = v29 + 4;
				v50 = 1;
			end
			if (v50 == 1) then
				return (v54 * (9847815 + 6929401)) + (v53 * 65536) + (v52 * 256) + v51;
			end
		end
	end
	local function v35()
		local v55 = 0;
		local v56;
		local v57;
		local v58;
		local v59;
		local v60;
		local v61;
		while true do
			if ((1404 == 1404) and (3 == v55)) then
				if (v60 == 0) then
					if ((v59 == 0) or (3748 < 2212)) then
						return v61 * 0;
					else
						v60 = 1;
						v58 = 0;
					end
				elseif ((1152 == 1152) and (v60 == (3951 - 1904))) then
					return ((v59 == (0 - 0)) and (v61 * ((620 - (555 + 64)) / 0))) or (v61 * NaN);
				end
				return v16(v61, v60 - 1023) * (v58 + (v59 / (2 ^ 52)));
			end
			if ((1896 <= 3422) and (v55 == 2)) then
				v60 = v31(v57, 21, 31);
				v61 = ((v31(v57, 32) == 1) and -1) or 1;
				v55 = 3;
			end
			if (v55 == 1) then
				v58 = 1;
				v59 = (v31(v57, 1, 20) * (2 ^ 32)) + v56;
				v55 = 2;
			end
			if (v55 == 0) then
				v56 = v34();
				v57 = v34();
				v55 = 1;
			end
		end
	end
	local function v36(v62)
		local v63;
		if (not v62 or (1180 == 2180)) then
			v62 = v34();
			if ((v62 == (0 - 0)) or (990 > 1620)) then
				return "";
			end
		end
		v63 = v11(v27, v29, (v29 + v62) - 1);
		v29 = v29 + v62;
		local v64 = {};
		for v78 = 1, #v63 do
			v64[v78] = v10(v9(v11(v63, v78, v78)));
		end
		return v14(v64);
	end
	local v37 = v34;
	local function v38(...)
		return {...}, v20("#", ...);
	end
	local function v39()
		local v65 = {};
		local v66 = {};
		local v67 = {};
		local v68 = {v65,v66,nil,v67};
		local v69 = v34();
		local v70 = {};
		for v80 = 1, v69 do
			local v81 = 0;
			local v82;
			local v83;
			while true do
				if (((4090 < 4653) and (v81 == 0)) or (877 > 4695)) then
					v82 = v32();
					v83 = nil;
					v81 = 1;
				end
				if ((2691 >= 1851) and (1 == v81)) then
					if ((v82 == 1) or (2652 < 196) or (2985 >= 4856)) then
						v83 = v32() ~= (859 - (814 + 45));
					elseif ((4276 >= 1195) and (4135 < 4817) and (v82 == 2)) then
						v83 = v35();
					elseif (v82 == 3) then
						v83 = v36();
					end
					v70[v80] = v83;
					break;
				end
			end
		end
		v68[3] = v32();
		for v84 = 1, v34() do
			local v85 = v32();
			if ((272 == 272) and (v31(v85, 2 - 1, 1) == 0)) then
				local v110 = 0;
				local v111;
				local v112;
				local v113;
				while true do
					if ((3232 <= 4690) and (v110 == 2)) then
						if (((100 <= 3123) and (v31(v112, 1, 1081 - (1020 + 60)) == 1)) or (896 >= 3146)) then
							v113[929 - (214 + 713)] = v70[v113[2]];
						end
						if ((3061 >= 2958) and (v31(v112, 1 + 1, 1 + 1) == 1)) then
							v113[880 - (282 + 595)] = v70[v113[3]];
						end
						v110 = 3;
					end
					if ((v110 == 0) or (1369 > 4987)) then
						v111 = v31(v85, 2, 3);
						v112 = v31(v85, 1 + 3, 6);
						v110 = 1;
					end
					if ((3187 >= 644) and ((v110 == 1) or (863 >= 4584))) then
						v113 = {v33(),v33(),nil,nil};
						if ((v111 == (931 - (857 + 74))) or (724 >= 1668)) then
							local v126 = 0;
							while true do
								if (v126 == 0) then
									v113[3] = v33();
									v113[4] = v33();
									break;
								end
							end
						elseif (v111 == (886 - (261 + 624))) then
							v113[3] = v34();
						elseif ((644 <= 704) and (428 < 1804) and (v111 == 2)) then
							v113[3] = v34() - (2 ^ 16);
						elseif (v111 == 3) then
							local v201 = 0;
							while true do
								if (0 == v201) then
									v113[3] = v34() - (2 ^ 16);
									v113[572 - (367 + 201)] = v33();
									break;
								end
							end
						end
						v110 = 2;
					end
					if (v110 == 3) then
						if ((958 > 947) and (v31(v112, 3, 3) == 1)) then
							v113[4] = v70[v113[4]];
						end
						v65[v84] = v113;
						break;
					end
				end
			end
		end
		for v86 = 1, v34() do
			v66[v86 - 1] = v39();
		end
		return v68;
	end
	local function v40(v72, v73, v74)
		local v75 = v72[1];
		local v76 = v72[2];
		local v77 = v72[3];
		return function(...)
			local v88 = v75;
			local v89 = v76;
			local v90 = v77;
			local v91 = v38;
			local v92 = 1;
			local v93 = -1;
			local v94 = {};
			local v95 = {...};
			local v96 = v20("#", ...) - (1424 - (630 + 793));
			local v97 = {};
			local v98 = {};
			for v107 = 0, v96 do
				if ((4492 >= 2654) and ((v107 >= v90) or (3325 > 4613))) then
					v94[v107 - v90] = v95[v107 + 1];
				else
					v98[v107] = v95[v107 + (3 - 2)];
				end
			end
			local v99 = (v96 - v90) + 1;
			local v100;
			local v101;
			while true do
				v100 = v88[v92];
				v101 = v100[1];
				if (v101 <= 18) then
					if ((3442 >= 1503) and ((v101 <= 8) or (4950 <= 4553))) then
						if (v101 <= 3) then
							if ((v101 <= 1) or (3170 <= 1464)) then
								if (v101 == 0) then
									v98[v100[2]] = v74[v100[3]];
								else
									v98[v100[2]] = v98[v100[3]] % v98[v100[4]];
								end
							elseif ((v101 > 2) or (4797 == 4388)) then
								for v194 = v100[2], v100[3] do
									v98[v194] = nil;
								end
							else
								local v136 = 0;
								local v137;
								local v138;
								while true do
									if ((551 <= 681) and (0 == v136)) then
										v137 = v100[1639 - (1523 + 114)];
										v138 = v98[v137];
										v136 = 1;
									end
									if (v136 == 1) then
										for v346 = v137 + 1, v93 do
											v15(v138, v98[v346]);
										end
										break;
									end
								end
							end
						elseif ((3277 > 407) and (2665 <= 3933) and (v101 <= 5)) then
							if ((4695 >= 1415) and (3273 == 3273) and (v101 > 4)) then
								do
									return v98[v100[2]]();
								end
							else
								v98[v100[2 + 0]] = v100[14 - 11] + v98[v100[4]];
							end
						elseif ((v101 <= 6) or (3212 <= 944)) then
							v98[v100[1 + 1]]();
						elseif (v101 > 7) then
							if ((3824 > 409) and v98[v100[2 - 0]]) then
								v92 = v92 + 1;
							else
								v92 = v100[3];
							end
						else
							v98[v100[2]] = v73[v100[1068 - (68 + 997)]];
						end
					elseif ((v101 <= 13) or (3096 <= 1798)) then
						if ((2087 == 2087) and (v101 <= 10)) then
							if ((v101 == 9) or (3404 > 4503)) then
								local v140 = 0;
								local v141;
								local v142;
								local v143;
								local v144;
								while true do
									if ((3537 == 3537) and (5 == v140)) then
										v144 = v100[1749 - (760 + 987)];
										v98[v144] = v98[v144](v21(v98, v144 + 1, v93));
										v92 = v92 + 1;
										v100 = v88[v92];
										v140 = 6;
									end
									if ((3837 >= 1570) and ((v140 == 0) or (3506 <= 1309))) then
										v141 = nil;
										v142, v143 = nil;
										v144 = nil;
										v98[v100[2]] = v100[1273 - (226 + 1044)];
										v140 = 1;
									end
									if (v140 == 6) then
										if (((2955 == 2955) and (v98[v100[1915 - (1789 + 124)]] == v100[770 - (745 + 21)])) or (2950 == 3812)) then
											v92 = v92 + 1;
										else
											v92 = v100[120 - (32 + 85)];
										end
										break;
									end
									if ((4723 >= 2318) and (v140 == 2)) then
										v92 = v92 + (4 - 3);
										v100 = v88[v92];
										v98[v100[2]] = v100[3];
										v92 = v92 + 1;
										v140 = 3;
									end
									if ((v140 == 4) or (2903 == 1495) or (2027 > 2852)) then
										v141 = 0;
										for v348 = v144, v93 do
											local v349 = 0;
											while true do
												if ((v349 == 0) or (1136 > 4317)) then
													v141 = v141 + 1;
													v98[v348] = v142[v141];
													break;
												end
											end
										end
										v92 = v92 + 1;
										v100 = v88[v92];
										v140 = 5;
									end
									if ((4748 == 4748) and (4546 >= 2275) and (v140 == 1)) then
										v92 = v92 + 1;
										v100 = v88[v92];
										v144 = v100[6 - 4];
										v98[v144] = v98[v144](v21(v98, v144 + 1, v100[3]));
										v140 = 2;
									end
									if ((3736 <= 4740) and (819 >= 22) and (3 == v140)) then
										v100 = v88[v92];
										v144 = v100[2];
										v142, v143 = v91(v98[v144](v21(v98, v144 + 1, v100[3])));
										v93 = (v143 + v144) - 1;
										v140 = 4;
									end
								end
							else
								v98[v100[2]] = v98[v100[2 + 1]][v100[4]];
							end
						elseif (((3162 == 3162) and (v101 <= 11)) or (3390 <= 3060)) then
							v98[v100[5 - 3]] = v98[v100[3]] % v100[4];
						elseif ((v101 == 12) or (2369 > 4429)) then
							if ((4095 >= 3183) and (v98[v100[2]] == v100[4])) then
								v92 = v92 + 1;
							else
								v92 = v100[3];
							end
						else
							v98[v100[2]] = v98[v100[3]] + v100[4];
						end
					elseif (v101 <= 15) then
						if ((v101 > 14) or (3711 < 1008)) then
							local v148 = 0;
							local v149;
							local v150;
							local v151;
							local v152;
							while true do
								if (2 == v148) then
									for v351 = v149, v93 do
										v152 = v152 + 1;
										v98[v351] = v150[v152];
									end
									break;
								end
								if ((v148 == 1) or (999 > 2693)) then
									v93 = (v151 + v149) - 1;
									v152 = 0;
									v148 = 2;
								end
								if (v148 == 0) then
									v149 = v100[2];
									v150, v151 = v91(v98[v149](v21(v98, v149 + 1, v100[3])));
									v148 = 1;
								end
							end
						else
							v98[v100[2]] = {};
						end
					elseif ((v101 <= (62 - 46)) or (1049 <= 906)) then
						local v154 = 0;
						local v155;
						local v156;
						local v157;
						local v158;
						local v159;
						while true do
							if ((463 < 601) and (3 == v154)) then
								v100 = v88[v92];
								v98[v100[2]] = v100[13 - 10];
								v92 = v92 + 1;
								v100 = v88[v92];
								v159 = v100[2];
								v156, v157 = v91(v98[v159](v21(v98, v159 + 1, v100[3])));
								v154 = 4;
							end
							if (((4513 > 2726) and (0 == v154)) or (2183 < 687)) then
								v155 = nil;
								v156, v157 = nil;
								v158 = nil;
								v159 = nil;
								v98[v100[2]] = v74[v100[3]];
								v92 = v92 + 1;
								v154 = 1;
							end
							if ((4549 == 4549) and ((v154 == 5) or (1481 >= 2658))) then
								v156, v157 = v91(v98[v159](v21(v98, v159 + 1, v93)));
								v93 = (v157 + v159) - 1;
								v155 = 0 - 0;
								for v354 = v159, v93 do
									local v355 = 0;
									while true do
										if ((4672 == 4672) and (v355 == 0)) then
											v155 = v155 + 1;
											v98[v354] = v156[v155];
											break;
										end
									end
								end
								v92 = v92 + (1 - 0);
								v100 = v88[v92];
								v154 = 6;
							end
							if ((v154 == 1) or (3220 == 1364)) then
								v100 = v88[v92];
								v159 = v100[2];
								v158 = v98[v100[3 + 0]];
								v98[v159 + 1] = v158;
								v98[v159] = v158[v100[1 + 3]];
								v92 = v92 + 1 + 0;
								v154 = 2;
							end
							if ((v154 == 4) or (1054 > 3392)) then
								v93 = (v157 + v159) - 1;
								v155 = 0;
								for v356 = v159, v93 do
									v155 = v155 + 1;
									v98[v356] = v156[v155];
								end
								v92 = v92 + (2 - 1);
								v100 = v88[v92];
								v159 = v100[2 + 0];
								v154 = 5;
							end
							if ((v154 == 7) or (676 >= 1642) or (3668 < 395)) then
								v100 = v88[v92];
								v92 = v100[3];
								break;
							end
							if ((v154 == 6) or (4166 == 455)) then
								v159 = v100[2];
								v98[v159] = v98[v159](v21(v98, v159 + 1, v93));
								v92 = v92 + 1;
								v100 = v88[v92];
								v98[v100[2]]();
								v92 = v92 + 1;
								v154 = 7;
							end
							if (v154 == 2) then
								v100 = v88[v92];
								v98[v100[2]] = v73[v100[3 + 0]];
								v92 = v92 + (1056 - (87 + 968));
								v100 = v88[v92];
								v98[v100[959 - (892 + 65)]] = v100[3];
								v92 = v92 + 1;
								v154 = 3;
							end
						end
					elseif (v101 == 17) then
						v98[v100[2]] = #v98[v100[4 - 1]];
					else
						local v206 = 0;
						local v207;
						while true do
							if (v206 == 0) then
								v207 = v100[1415 - (447 + 966)];
								do
									return v98[v207](v21(v98, v207 + (351 - (87 + 263)), v100[3]));
								end
								break;
							end
						end
					end
				elseif (v101 <= (207 - (67 + 113))) then
					if (v101 <= (17 + 5)) then
						if (v101 <= 20) then
							if ((v101 > 19) or (4449 == 2663)) then
								local v160 = v100[4 - 2];
								local v161, v162 = v91(v98[v160](v21(v98, v160 + 1, v93)));
								v93 = (v162 + v160) - 1;
								local v163 = 0;
								for v196 = v160, v93 do
									local v197 = 0;
									while true do
										if ((4136 > 2397) and (v197 == 0)) then
											v163 = v163 + 1;
											v98[v196] = v161[v163];
											break;
										end
									end
								end
							else
								local v164 = 0;
								local v165;
								local v166;
								local v167;
								local v168;
								local v169;
								while true do
									if (v164 == 1) then
										v98[v100[2 + 0]] = v73[v100[3]];
										v92 = v92 + (3 - 2);
										v100 = v88[v92];
										v98[v100[703 - (376 + 325)]] = v73[v100[3]];
										v164 = 2;
									end
									if ((2 == v164) or (4277 < 2989)) then
										v92 = v92 + (1 - 0);
										v100 = v88[v92];
										v98[v100[2]] = v73[v100[3]];
										v92 = v92 + (953 - (802 + 150));
										v164 = 3;
									end
									if ((v164 == 5) or (4334 == 4245) or (870 >= 4149)) then
										v92 = v92 + 1 + 0;
										v100 = v88[v92];
										for v361 = v100[2], v100[1000 - (915 + 82)] do
											v98[v361] = nil;
										end
										v92 = v92 + 1;
										v164 = 6;
									end
									if ((2212 < 3183) and ((6 == v164) or (4276 <= 3031))) then
										v100 = v88[v92];
										v169 = v100[2];
										v167, v168 = v91(v98[v169](v21(v98, v169 + 1, v100[3])));
										v93 = (v168 + v169) - 1;
										v164 = 7;
									end
									if (v164 == 3) then
										v100 = v88[v92];
										v98[v100[2]] = {};
										v92 = v92 + 1;
										v100 = v88[v92];
										v164 = 4;
									end
									if ((4646 > 2992) and (v164 == 0)) then
										v165 = nil;
										v166 = nil;
										v167, v168 = nil;
										v169 = nil;
										v164 = 1;
									end
									if (v164 == 4) then
										v98[v100[2]] = v73[v100[3]];
										v92 = v92 + (2 - 1);
										v100 = v88[v92];
										v98[v100[2]] = v98[v100[5 - 2]];
										v164 = 5;
									end
									if ((1434 < 3106) and ((v164 == 8) or (4782 <= 1199))) then
										v169 = v100[2];
										v165 = v98[v169];
										for v363 = v169 + 1, v93 do
											v15(v165, v98[v363]);
										end
										break;
									end
									if (v164 == 7) then
										v166 = 0;
										for v364 = v169, v93 do
											local v365 = 0;
											while true do
												if (v365 == 0) then
													v166 = v166 + 1;
													v98[v364] = v167[v166];
													break;
												end
											end
										end
										v92 = v92 + 1;
										v100 = v88[v92];
										v164 = 8;
									end
								end
							end
						elseif ((786 < 3023) and ((v101 > (59 - 38)) or (4864 < 1902))) then
							v92 = v100[3];
						else
							local v171 = v100[2];
							local v172, v173 = v91(v98[v171](v98[v171 + 1]));
							v93 = (v173 + v171) - (1 + 0);
							local v174 = 0;
							for v198 = v171, v93 do
								v174 = v174 + 1 + 0;
								v98[v198] = v172[v174];
							end
						end
					elseif ((4839 >= 3700) and (v101 <= (52 - 28))) then
						if (v101 > (37 - (9 + 5))) then
							if not v98[v100[2]] then
								v92 = v92 + 1;
							else
								v92 = v100[379 - (85 + 291)];
							end
						else
							local v175 = v100[2];
							local v176 = v98[v175];
							local v177 = v98[v175 + 2];
							if ((v177 > 0) or (2442 < 74)) then
								if ((4535 == 4535) and (v176 > v98[v175 + 1])) then
									v92 = v100[3];
								else
									v98[v175 + 3] = v176;
								end
							elseif ((v176 < v98[v175 + 1]) or (1075 > 1918) or (3009 <= 2105)) then
								v92 = v100[3];
							else
								v98[v175 + 3] = v176;
							end
						end
					elseif (v101 <= (32 - 7)) then
						local v178 = v100[2];
						v98[v178](v21(v98, v178 + 1, v93));
					elseif ((1830 < 3669) and (v101 == 26)) then
						local v209 = 0;
						while true do
							if ((396 <= 3804) and (v209 == 1)) then
								v98[v100[2]] = v98[v100[3]][v100[4]];
								v92 = v92 + (1266 - (243 + 1022));
								v100 = v88[v92];
								v209 = 2;
							end
							if ((v209 == 3) or (4169 == 2187)) then
								v98[v100[2]] = v98[v100[3]][v100[1191 - (1069 + 118)]];
								v92 = v92 + 1;
								v100 = v88[v92];
								v209 = 4;
							end
							if (v209 == 6) then
								v98[v100[2]] = v74[v100[3]];
								v92 = v92 + 1;
								v100 = v88[v92];
								v209 = 7;
							end
							if (v209 == 0) then
								v98[v100[2]] = v74[v100[3]];
								v92 = v92 + 1;
								v100 = v88[v92];
								v209 = 1;
							end
							if (v209 == 4) then
								v98[v100[2]] = v74[v100[3]];
								v92 = v92 + 1;
								v100 = v88[v92];
								v209 = 5;
							end
							if (v209 == 7) then
								if ((1406 == 1406) and not v98[v100[2]]) then
									v92 = v92 + 1;
								else
									v92 = v100[3];
								end
								break;
							end
							if (v209 == 5) then
								v98[v100[2]] = v98[v100[3]][v100[4]];
								v92 = v92 + 1;
								v100 = v88[v92];
								v209 = 6;
							end
							if ((1531 < 4271) and (v209 == 2)) then
								v98[v100[2]] = v74[v100[3]];
								v92 = v92 + 1;
								v100 = v88[v92];
								v209 = 3;
							end
						end
					else
						v98[v100[2]] = v98[v100[3]];
					end
				elseif ((635 == 635) and (v101 <= (72 - 40))) then
					if ((v101 <= 29) or (1430 >= 3612)) then
						if (v101 == 28) then
							local v179 = 0;
							local v180;
							while true do
								if ((2683 >= 2460) and (0 == v179)) then
									v180 = v100[2];
									v98[v180] = v98[v180](v21(v98, v180 + 1, v100[3]));
									break;
								end
							end
						else
							local v181 = 0;
							local v182;
							local v183;
							local v184;
							local v185;
							while true do
								if ((v181 == 12) or (1804 >= 3275)) then
									v92 = v92 + 1;
									v100 = v88[v92];
									v98[v100[2]] = v98[v100[11 - 8]] % v100[446 - (416 + 26)];
									v92 = v92 + 1;
									v100 = v88[v92];
									v185 = v100[2];
									v183, v184 = v91(v98[v185](v98[v185 + 1]));
									v181 = 13;
								end
								if ((3373 <= 3556) and (v181 == 7)) then
									v100 = v88[v92];
									v98[v100[2]] = v98[v100[3]] % v98[v100[4]];
									v92 = v92 + 1;
									v100 = v88[v92];
									v98[v100[2]] = v100[1933 - (1869 + 61)] + v98[v100[4]];
									v92 = v92 + 1;
									v100 = v88[v92];
									v181 = 8;
								end
								if ((10 == v181) or (3291 < 3280)) then
									v93 = (v184 + v185) - (1 + 0);
									v182 = 0;
									for v370 = v185, v93 do
										local v371 = 0;
										while true do
											if (((4386 >= 873) and (0 == v371)) or (1417 > 3629)) then
												v182 = v182 + 1;
												v98[v370] = v183[v182];
												break;
											end
										end
									end
									v92 = v92 + 1;
									v100 = v88[v92];
									v185 = v100[2];
									v183, v184 = v91(v98[v185](v21(v98, v185 + 1, v93)));
									v181 = 11;
								end
								if ((921 <= 1102) and (v181 == 1)) then
									v92 = v92 + 1;
									v100 = v88[v92];
									v98[v100[2]] = v73[v100[3]];
									v92 = v92 + 1;
									v100 = v88[v92];
									v98[v100[2]] = v73[v100[3]];
									v92 = v92 + 1;
									v181 = 2;
								end
								if ((4795 > 402) and (4706 >= 963) and (v181 == 3)) then
									v98[v100[2]] = v98[v100[1 + 2]];
									v92 = v92 + 1;
									v100 = v88[v92];
									v98[v100[2]] = v98[v100[3]] + v100[1184 - (1123 + 57)];
									v92 = v92 + 1;
									v100 = v88[v92];
									v185 = v100[2];
									v181 = 4;
								end
								if ((4813 > 3565) and ((6 == v181) or (960 <= 876))) then
									v92 = v92 + 1;
									v100 = v88[v92];
									v98[v100[2]] = v98[v100[3]];
									v92 = v92 + 1;
									v100 = v88[v92];
									v98[v100[2]] = #v98[v100[3]];
									v92 = v92 + 1;
									v181 = 7;
								end
								if ((3912 == 3912) and ((v181 == 13) or (2066 == 932))) then
									v93 = (v184 + v185) - 1;
									v182 = 0 + 0;
									for v372 = v185, v93 do
										v182 = v182 + 1;
										v98[v372] = v183[v182];
									end
									v92 = v92 + (3 - 2);
									v100 = v88[v92];
									v185 = v100[2];
									v98[v185](v21(v98, v185 + 1, v93));
									break;
								end
								if (v181 == 4) then
									v183, v184 = v91(v98[v185](v21(v98, v185 + 1, v100[3])));
									v93 = (v184 + v185) - 1;
									v182 = 0;
									for v375 = v185, v93 do
										local v376 = 0;
										while true do
											if (v376 == 0) then
												v182 = v182 + 1;
												v98[v375] = v183[v182];
												break;
											end
										end
									end
									v92 = v92 + 1;
									v100 = v88[v92];
									v185 = v100[2];
									v181 = 5;
								end
								if ((2821 <= 4824) and (4825 < 4843) and (v181 == 0)) then
									v182 = nil;
									v183, v184 = nil;
									v185 = nil;
									v98[v100[2]] = v98[v100[3]];
									v92 = v92 + 1;
									v100 = v88[v92];
									v98[v100[7 - 5]] = v73[v100[3 + 0]];
									v181 = 1;
								end
								if ((1738 <= 2195) and ((v181 == 11) or (3877 >= 4537))) then
									v93 = (v184 + v185) - 1;
									v182 = 0;
									for v377 = v185, v93 do
										local v378 = 0;
										while true do
											if ((41 <= 3018) and (v378 == 0)) then
												v182 = v182 + 1;
												v98[v377] = v183[v182];
												break;
											end
										end
									end
									v92 = v92 + 1;
									v100 = v88[v92];
									v185 = v100[2];
									v98[v185] = v98[v185](v21(v98, v185 + 1, v93));
									v181 = 12;
								end
								if (v181 == 5) then
									v98[v185] = v98[v185](v21(v98, v185 + 1 + 0, v93));
									v92 = v92 + 1;
									v100 = v88[v92];
									v98[v100[2]] = v73[v100[3]];
									v92 = v92 + 1;
									v100 = v88[v92];
									v98[v100[256 - (163 + 91)]] = v73[v100[3]];
									v181 = 6;
								end
								if ((v181 == 9) or (4315 < 1726)) then
									v92 = v92 + (792 - (368 + 423));
									v100 = v88[v92];
									v98[v100[6 - 4]] = v98[v100[3]] + v100[22 - (10 + 8)];
									v92 = v92 + 1;
									v100 = v88[v92];
									v185 = v100[2];
									v183, v184 = v91(v98[v185](v21(v98, v185 + 1, v100[3])));
									v181 = 10;
								end
								if ((v181 == 8) or (3679 < 625)) then
									v98[v100[2]] = #v98[v100[3]];
									v92 = v92 + (1 - 0);
									v100 = v88[v92];
									v98[v100[2 + 0]] = v98[v100[3]] % v98[v100[4]];
									v92 = v92 + 1;
									v100 = v88[v92];
									v98[v100[1 + 1]] = v100[3] + v98[v100[4]];
									v181 = 9;
								end
								if ((2145 <= 4104) and ((v181 == 2) or (4625 < 632))) then
									v100 = v88[v92];
									v98[v100[2]] = v73[v100[3]];
									v92 = v92 + (1 - 0);
									v100 = v88[v92];
									v98[v100[2]] = v98[v100[3]];
									v92 = v92 + 1;
									v100 = v88[v92];
									v181 = 3;
								end
							end
						end
					elseif ((2689 < 4845) and ((v101 <= 30) or (83 > 1780))) then
						v98[v100[2]] = v100[3];
					elseif ((546 <= 1077) and (v101 > 31)) then
						local v212 = 0;
						local v213;
						local v214;
						while true do
							if ((v212 == 1) or (2322 > 2622)) then
								v98[v213 + 1] = v214;
								v98[v213] = v214[v100[2 + 2]];
								break;
							end
							if ((v212 == 0) or (996 > 4301) or (4534 == 2082)) then
								v213 = v100[2];
								v214 = v98[v100[1477 - (1329 + 145)]];
								v212 = 1;
							end
						end
					else
						local v215 = 0;
						local v216;
						local v217;
						local v218;
						while true do
							if (((4070 > 687) and (v215 == 2)) or (1571 > 1867)) then
								for v414 = 1, v100[975 - (140 + 831)] do
									local v415 = 0;
									local v416;
									while true do
										if ((v415 == 0) or (656 >= 3330) or (2654 >= 2996)) then
											v92 = v92 + 1;
											v416 = v88[v92];
											v415 = 1;
										end
										if ((v415 == 1) or (2492 <= 335)) then
											if ((3978 > 2104) and (v416[1851 - (1409 + 441)] == 27)) then
												v218[v414 - (719 - (15 + 703))] = {v98,v416[3]};
											else
												v218[v414 - 1] = {v73,v416[3]};
											end
											v97[#v97 + 1 + 0] = v218;
											break;
										end
									end
								end
								v98[v100[1488 - (998 + 488)]] = v40(v216, v217, v74);
								break;
							end
							if (v215 == 1) then
								v218 = {};
								v217 = v18({}, {[v7("\27\73\27\243\49\49\227", "\54\68\22\114\157\85\84\155")]=function(v417, v418)
									local v419 = v218[v418];
									return v419[1][v419[2]];
								end,[v7("\244\44\202\88\225\35\141\192\206\11", "\164\171\115\164\61\150\74\227")]=function(v420, v421, v422)
									local v423 = v218[v421];
									v423[1][v423[440 - (145 + 293)]] = v422;
								end});
								v215 = 2;
							end
							if ((2995 > 1541) and (4322 >= 2562) and (v215 == 0)) then
								v216 = v89[v100[4 - 1]];
								v217 = nil;
								v215 = 1;
							end
						end
					end
				elseif (v101 <= 34) then
					if ((3249 > 953) and (v101 == 33)) then
						do
							return;
						end
					else
						local v188 = 0;
						local v189;
						local v190;
						local v191;
						while true do
							if ((v188 == 1) or (3637 >= 3770) or (3273 > 4573)) then
								v92 = v92 + 1;
								v100 = v88[v92];
								v98[v100[2]] = v100[3];
								v92 = v92 + 1 + 0;
								v188 = 2;
							end
							if ((2 == v188) or (2379 > 4578)) then
								v100 = v88[v92];
								v98[v100[2 + 0]] = #v98[v100[441 - (262 + 176)]];
								v92 = v92 + 1;
								v100 = v88[v92];
								v188 = 3;
							end
							if ((v188 == 4) or (483 > 743) or (3151 < 1284)) then
								v190 = v98[v191];
								v189 = v98[v191 + 2];
								if (((2454 > 578) and (v189 > 0)) or (1850 == 1529)) then
									if ((821 < 2123) and (v190 > v98[v191 + 1])) then
										v92 = v100[3];
									else
										v98[v191 + 3] = v190;
									end
								elseif (v190 < v98[v191 + 1]) then
									v92 = v100[691 - (198 + 490)];
								else
									v98[v191 + 3] = v190;
								end
								break;
							end
							if (v188 == 0) then
								v189 = nil;
								v190 = nil;
								v191 = nil;
								v98[v100[2]] = {};
								v188 = 1;
							end
							if ((902 < 2325) and (v188 == 3)) then
								v98[v100[1723 - (345 + 1376)]] = v100[3];
								v92 = v92 + 1;
								v100 = v88[v92];
								v191 = v100[2];
								v188 = 4;
							end
						end
					end
				elseif ((858 <= 2962) and (930 < 4458) and (v101 <= 35)) then
					local v192 = 0;
					local v193;
					while true do
						if (((662 <= 972) and (v192 == 0)) or (3946 < 1288)) then
							v193 = v100[2];
							v98[v193] = v98[v193](v21(v98, v193 + 1, v93));
							break;
						end
					end
				elseif (v101 > 36) then
					local v219 = v100[2];
					do
						return v21(v98, v219, v93);
					end
				else
					local v220 = 0;
					local v221;
					local v222;
					local v223;
					while true do
						if (((4370 == 4370) and (v220 == 2)) or (3242 == 567)) then
							if ((v222 > (0 - 0)) or (4762 <= 861)) then
								if (v223 <= v98[v221 + 1]) then
									local v444 = 0;
									while true do
										if ((v444 == 0) or (1412 == 4264) or (847 >= 1263)) then
											v92 = v100[3];
											v98[v221 + 3] = v223;
											break;
										end
									end
								end
							elseif ((v223 >= v98[v221 + (2 - 1)]) or (3168 < 2153)) then
								local v445 = 0;
								while true do
									if ((v445 == 0) or (2253 == 1851)) then
										v92 = v100[3];
										v98[v221 + 3] = v223;
										break;
									end
								end
							end
							break;
						end
						if (v220 == 1) then
							v223 = v98[v221] + v222;
							v98[v221] = v223;
							v220 = 2;
						end
						if ((0 == v220) or (4976 < 1332) or (2087 > 2372)) then
							v221 = v100[2];
							v222 = v98[v221 + 2];
							v220 = 1;
						end
					end
				end
				v92 = v92 + (773 - (201 + 571));
			end
		end;
	end
	return v40(v39(), {}, v28)(...);
end
return v23("LOL!0D3Q0003063Q00737472696E6703043Q006368617203043Q00627974652Q033Q0073756203053Q0062697433322Q033Q0062697403043Q0062786F7203053Q007461626C6503063Q00636F6E63617403063Q00696E7365727403053Q006D6174636803083Q00746F6E756D62657203053Q007063612Q6C00243Q00121A3Q00013Q00206Q000200122Q000100013Q00202Q00010001000300122Q000200013Q00202Q00020002000400122Q000300053Q00062Q0003000A000100010004163Q000A000100122Q000300063Q00200A00040003000700122Q000500083Q00200A00050005000900122Q000600083Q00200A00060006000A00061F00073Q000100062Q001B3Q00064Q001B8Q001B3Q00044Q001B3Q00014Q001B3Q00024Q001B3Q00053Q00122Q000800013Q00200A00080008000B00122Q0009000C3Q00122Q000A000D3Q00061F000B0001000100052Q001B3Q00074Q001B3Q00094Q001B3Q00084Q001B3Q000A4Q001B3Q000B4Q001B000C000B4Q0005000C00014Q0025000C6Q00213Q00013Q00023Q00023Q00026Q00F03F026Q00704002264Q002200025Q00122Q000300016Q00045Q00122Q000500013Q00042Q0003002100012Q000700076Q001D000800026Q000900016Q000A00026Q000B00036Q000C00046Q000D8Q000E00063Q00202Q000F000600014Q000C000F6Q000B3Q00024Q000C00036Q000D00046Q000E00016Q000F00016Q000F0006000F00102Q000F0001000F4Q001000016Q00100006001000102Q00100001001000202Q0010001000014Q000D00106Q000C8Q000A3Q000200202Q000A000A00024Q0009000A6Q00073Q00010004240003000500012Q0007000300054Q001B000400024Q0012000300044Q002500036Q00213Q00017Q00043Q00027Q004003053Q003A25642B3A2Q033Q0025642B026Q00F03F001C3Q00061F5Q000100012Q00078Q0013000100016Q000200026Q000300026Q00048Q000500036Q00068Q000700076Q000500076Q00043Q000100200A000400040001001209000500026Q00030005000200122Q000400036Q000200046Q00013Q000200262Q00010018000100040004163Q001800012Q001B00016Q000E00026Q0012000100024Q002500015Q0004163Q001B00012Q0007000100044Q0005000100014Q002500016Q00213Q00013Q00013Q00063Q00030A3Q006C6F6164737472696E6703043Q0067616D6503073Q00482Q747047657403223Q00D9D7CF35F5E18851C5C6C331E4B2C950DFC6CF6AF4BAD051C7D9D62CEDE2D449D79603083Q007EB1A3BB4586DBA7026Q00F03F010F3Q0006083Q000D00013Q0004163Q000D000100122Q000100013Q001210000200023Q00202Q0002000200034Q00045Q00122Q000500043Q00122Q000600056Q000400066Q00028Q00013Q00024Q00010001000100044Q000E000100200A00013Q00062Q00213Q00017Q00", v17(), ...);
