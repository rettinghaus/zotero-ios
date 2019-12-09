/*
	***** BEGIN LICENSE BLOCK *****
	
	Copyright © 2018 Center for History and New Media
					George Mason University, Fairfax, Virginia, USA
					http://zotero.org
	
	This file is part of Zotero.
	
	Zotero is free software: you can redistribute it and/or modify
	it under the terms of the GNU Affero General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	Zotero is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Affero General Public License for more details.

	You should have received a copy of the GNU Affero General Public License
	along with Zotero.  If not, see <http://www.gnu.org/licenses/>.
	
	***** END LICENSE BLOCK *****
*/

Zotero.Translate = {...Zotero.Translate,
	SandboxManager,
	ItemSaver,
	ItemGetter
};

window.Services = {
	// nsIVersionComparator
	vc: {
		compare: function (a, b) {
			// Only worry about the major version (4. vs. 5.)
			var aParts = a.split(/\./g);
			var bParts = b.split(/\./g);
			return aParts[0] - bParts[0];
		}
	}
};
