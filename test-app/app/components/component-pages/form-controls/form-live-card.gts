import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { array, hash } from '@ember/helper';
import * as v from 'valibot';
import { Button, Form, type FormResultData } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';

const schema = v.object({
  name: v.pipe(v.string(), v.trim(), v.nonEmpty('Name is required')),
  email: v.pipe(
    v.string(),
    v.trim(),
    v.nonEmpty('Email is required'),
    v.email('Enter a valid email address')
  )
});

type LiveData = v.InferOutput<typeof schema>;

/**
 * A real Form: validated on submit (required and email format) by a Valibot
 * schema, with the submitted data printed underneath.
 */
export default class FormLiveCard extends Component {
  @tracked submitted: string | null = null;

  submit = (result: FormResultData<LiveData>): void => {
    this.submitted = JSON.stringify(result.data, null, 2);
  };

  /** A rejected submit clears the last accepted one, so stale data never shows. */
  reject = (): void => {
    this.submitted = null;
  };

  reset = (): void => {
    this.submitted = null;
  };

  <template>
    <WorkbenchCard
      @id="form-live"
      @title="Live form"
      @description="A real Form with required and email-format validation. Submit it empty, then with a bad email, then with valid values."
      @sections={{array (hash id="form" label="Form")}}
    >
      <WorkbenchSection
        @id="form-live-form"
        @title="Form"
        @subtitle="Validated on submit by a Valibot schema"
      >
        <div class="grid gap-6 lg:grid-cols-2">
          <Form
            @schema={{schema}}
            @onSubmit={{this.submit}}
            @onError={{this.reject}}
            novalidate
            as |form|
          >
            <div class="flex max-w-sm flex-col gap-4">
              <form.Field @name="name" as |field|>
                <field.Input @label="Name" @isRequired={{true}} />
              </form.Field>
              <form.Field @name="email" as |field|>
                <field.Input
                  @label="Email"
                  @type="email"
                  @isRequired={{true}}
                  @description="Format is checked: name@domain"
                />
              </form.Field>
              <div class="flex gap-2">
                <Button type="submit" @color="primary">Submit</Button>
                <Button
                  type="reset"
                  @variant="outline"
                  @onPress={{this.reset}}
                >Reset</Button>
              </div>
            </div>
          </Form>
          <div class="flex flex-col gap-2">
            <p
              class="text-neutral-firm text-[11px] font-semibold tracking-wider uppercase"
            >Submitted</p>
            {{#if this.submitted}}
              <pre
                data-form-live-output
                class="bg-neutral-subtle text-neutral-strong rounded-md p-3 font-mono text-xs"
              >{{this.submitted}}</pre>
            {{else}}
              <p class="text-neutral-firm text-sm">Nothing submitted yet.</p>
            {{/if}}
          </div>
        </div>
      </WorkbenchSection>
    </WorkbenchCard>
  </template>
}
