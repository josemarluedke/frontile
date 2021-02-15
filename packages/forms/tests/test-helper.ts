// @ts-ignore
import Application from 'dummy/app';
import config from 'dummy/config/environment';
import QUnit from 'qunit';
import { setApplication } from '@ember/test-helpers';
import { start } from 'ember-qunit';
import { setup } from 'qunit-dom';

// @ts-ignore
setApplication(Application.create(config.APP));

setup(QUnit.assert);
start();
