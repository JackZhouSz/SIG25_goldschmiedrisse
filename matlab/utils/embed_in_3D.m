function updated_curves = embed_in_3D(unit_curves)
updated_curves = [];
for i = 1 : length(unit_curves)
  intersections = calculate_intersections(unit_curves(i));
  intersections = sortrows(intersections, [1, 2]);
  intersections = intersections(1,:);
  [a, b] = calc_beziers(unit_curves(i), intersections);
  updated_curves = [updated_curves, @() rasterize_3d_curve(unit_curves(i), a, b)];
end
end

function y = rasterize_3d_curve(curve, indices, bezier_coefs)
  pts = curve.unit_controlledCurve.anchor;
  constraints = curve.unit_controlledCurve.anchor_constraints;
  num = size(pts, 1);
  t = linspace(0, 1, 100);
  y = [];
  for ii = 1 : size(indices, 1)
      p1 = pts(indices(ii, 1), :);
      p2 = pts(indices(ii, 2), :);
      rast_pts = eval_cubic_bezier(t, bezier_coefs(ii, :));
      s = rast_pts(:, 1);
      if (isempty(constraints))
        y = [y; (1-s)*p1 + s*p2, rast_pts(:, 2)];
      else
        tangent_i = constraints(indices(ii, 1), :);
        tangent_j = constraints(indices(ii, 2), :);
        c1 = p1 + tangent_i;
        c2 = p2 + tangent_j;
        bezier_curve = @(t) ((1-t).^3 .* p1' + 3*(1-t).^2 .* t .* c1' + 3*(1-t) .* t.^2 .* c2' + t.^3 .* p2')';
        y = [y; bezier_curve(s'), rast_pts(:, 2)];
      end
  end
end
  

function [indices, bezier_coefs] = calc_beziers(curve, intersections)
  ind = 1;
  n_anchors = size(curve.unit_controlledCurve.anchor, 1);
  bezier_coefs = [];
  indices = [];
  for i = 2 : n_anchors
    ts = [0];
    while (ind <= size(intersections, 1)) && (intersections(ind, 1) == i - 1)
      ts = [ts; intersections(ind, 2)];
      ind = ind + 1;
    end
    ts = [ts; 1];
    bezier_coefs = [bezier_coefs; fit_height(ts, curve.unit_controlledCurve.anchor_label(i-1), ...
      curve.unit_controlledCurve.anchor_label(i))];
    indices = [indices; repmat([i-1, i], [size(ts, 1) - 1, 1])];
  end
end


function res = calculate_repeat_intersections(curve, mat)
% Check whether there's an intersection between pts
% and mat * pts.
res = [];
eps = 1e-6;
for i = 1 : size(curve.unit_controlledCurve.anchor, 1) - 1
  if isempty(curve.unit_controlledCurve.anchor_constraints)
    p1 = curve.unit_controlledCurve.anchor(i, :)';
    p2 = curve.unit_controlledCurve.anchor(i + 1, :)';
    p1_new = mat * p1;
    p2_new = mat * p2;
    [t, s] = find_intersections_2d(p1, p2, p1_new, p2_new);
    % Check if the line segments intersect (at the same time).
    if norm(s-t) < eps && norm(t) > eps && norm(t-1) > eps
      res = [res; i, t, p1' + t * (p2' - p1')];
    end
  else
    anchor_i = curve.unit_controlledCurve.anchor(i, :);
    anchor_j = curve.unit_controlledCurve.anchor(i + 1, :);
    tangent_i = curve.unit_controlledCurve.anchor_constraints(i, :);
    tangent_j = curve.unit_controlledCurve.anchor_constraints(i + 1, :);
    c1 = anchor_i + tangent_i;
    c2 = anchor_j + tangent_j;
    bezier_curve = @(t) ((1-t).^3 .* anchor_i' + 3*(1-t).^2 .* t .* c1' + 3*(1-t) .* t.^2 .* c2' + t.^3 .* anchor_j');
    bt = linspace(0, 1, 100);
    for j = 1 : length(bt) - 1
      p1 = bezier_curve(bt(j));
      p2 = bezier_curve(bt(j+1));
      p1_new = mat * p1;
      p2_new = mat * p2;
      [t, s] = find_intersections_2d(p1, p2, p1_new, p2_new);
      % Check if the line segments intersect (at the same time).
      if norm(s-t) < eps &&  norm(t-1) > eps && t > 0 &&  t < 1
        tt = bt(j) + t * (bt(j+1) - bt(j));
        res = [res; i, tt, p1' + t * (p2' - p1')];
      end
    end
    
  end
end
end

function res = calculate_intersections(curve)
res = [];
ref_mat = curve.get_reflection_mat();
rot_mat = curve.get_rotation_mat(1);
for i = 1 : curve.rotational_symmetry
  mat = rot_mat^i;
  % res = [res; calculate_repeat_intersections(curve, mat)];
  if curve.reflection_symmetry
    mat = mat * ref_mat;
    res = [res; calculate_repeat_intersections(curve, mat)];
  end
end
end