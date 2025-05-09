import * as THREE from 'three';

import { finish_curve, edit_mode, EditMode, delete_selected_curve, mode, set_edit_mode, background_image_plane } from '../state/state';
import { abort_new_face, find_all_faces, finish_face } from '../view/add_face_mode';
import { selected_obj } from './mouse';
import { accept_edit_decoration_point, cancel_edit_decoration_point, delete_decoration_point, edit_decoration_point } from './edit_decoration_point';
import { accept_height_change, cancel_height_change, start_changing_height } from './change_layer_height';
import { accept_edit_prc_point, cancel_edit_prc_point, edit_prc_point } from './set_prc';
import { accept_edit_vertical_line_top, cancel_edit_vertical_line_top, edit_vertical_line_top, remove_vertical_line } from './add_vertical_line';
import { accept_scale, init_scale } from './scale_background_image';
import { params } from '../state/params';
import { set_side_view, set_top_view } from '../view/visual';
import { view_controller } from '../view/gui';
import { show_help } from '..';

function is_body_active() {
  return document.activeElement.tagName == 'BODY';
}

addEventListener('keydown', (event) => {
  if (event.key == "Escape") {
    if (edit_mode == EditMode.new_curve) {
      finish_curve();
    } else if (edit_mode == EditMode.new_face) {
      abort_new_face();
    } else if (edit_mode == EditMode.edit_decoration_point) {
      cancel_edit_decoration_point();
    } else if (edit_mode == EditMode.edit_prc_point) {
      cancel_edit_prc_point();
    } else if (edit_mode == EditMode.edit_vertical_line_top) {
      cancel_edit_vertical_line_top();
    } else if (edit_mode == EditMode.change_layer_bottom) {
      cancel_height_change();
    } else if (edit_mode == EditMode.scale_background_image) {
      accept_scale();
    }
  } else if (is_body_active() && event.key == "Delete" || event.key == "Backspace") {
    if (edit_mode == EditMode.new_curve) {
      finish_curve();
    } else if (edit_mode == EditMode.edit_decoration_point) {
      delete_decoration_point();
    } else if (edit_mode == EditMode.edit_vertical_line_top) {
      remove_vertical_line();
    }
    delete_selected_curve(selected_obj);
  } else if (is_body_active() && event.key == 'Enter') {
    if (edit_mode == EditMode.new_face) {
      finish_face();
    } else if (edit_mode == EditMode.edit_decoration_point) {
      accept_edit_decoration_point();
    } else if (edit_mode == EditMode.edit_prc_point) {
      accept_edit_prc_point();
    } else if (edit_mode == EditMode.edit_vertical_line_top) {
      accept_edit_vertical_line_top();
    } else if (edit_mode == EditMode.change_layer_bottom) {
      accept_height_change();
    }
  } else if (is_body_active() && event.key == 'd' && selected_obj && selected_obj.type == 'unit_curve') {
    edit_decoration_point();
  } else if (is_body_active() && event.key == 'r' && selected_obj && selected_obj.type == 'unit_curve') {
    edit_prc_point();
  } else if (is_body_active() && event.key == 'h' && selected_obj && selected_obj.type == 'unit_curve') {
    edit_vertical_line_top();
  } else if (is_body_active() && event.key == 'h') {
    show_help();
  } else if (is_body_active() && event.key == 'g' && params.preview_mode == 'Design' && edit_mode == EditMode.none) {
    start_changing_height();
  } else if (is_body_active() && event.key == 'f') {
    find_all_faces();
  } else if (is_body_active() && event.key == 's' && background_image_plane) {
    set_edit_mode(EditMode.start_scale_background_image);
  } else if (is_body_active() && event.key == '1') {
    view_controller.controller.value.setRawValue('Ortho');
    set_top_view();
  } else if (is_body_active() && event.key == '2') {
    view_controller.controller.value.setRawValue('Ortho');
    set_side_view();
  } else if (is_body_active() && event.key == '3') {
    view_controller.controller.value.setRawValue('Perspective');
  }
});