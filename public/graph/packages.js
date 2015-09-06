(function() {
  packages = {

    // Lazily construct the package hierarchy from class names.
    root: function(classes) {
      var map = {};

      function find(name, data) {
        var node = map[name], i;
        if (!node) {
          node = map[name] = data || {name: name, children: []};
          if (name.length) {
            var parent_name, p
            if (p = name.match(/^(.*):(.*)$/)) {
              parent_name = p[1]
            } else if (p = name.match(/^(.*?)\.(.*)$/)) {
              parent_name = p[2]
            } else {
              parent_name = ''
            }
            node.parent = find(parent_name);
            if (!node.parent.children) {
              console.log('children', name, data)
              node.parent.children = []
            }
            node.parent.children.push(node);
            node.key = name.replace(/\W/g,'-');
          }
        }
        return node;
      }

      Object.keys(classes).forEach(function(k) {
        var v = classes[k]
        find(k, {name: k, size: v.pages, imports: v.links||[]});
      });

      return map[""];
    },

    // Return a list of imports for the given array of nodes.
    imports: function(nodes) {
      var map = {},
          imports = [];

      // Compute a map from name to node.
      nodes.forEach(function(d) {
        map[d.name] = d;
      });

      // For each import, construct a link from the source to target node.
      nodes.forEach(function(d) {
        if (d.imports) d.imports.forEach(function(i) {
          imports.push({source: map[d.name], target: map[i]});
        });
      });

      return imports;
    }

  };
})();
